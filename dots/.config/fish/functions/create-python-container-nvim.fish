function create-python-container-nvim --description "Create a secure Python development container with optional Neovim and LazyVim" --argument-names action name

    # ==================================================
    # Arguments
    # ==================================================

    if test "$action" != new
        echo "Usage:"
        echo "  create-python-container-nvim new <projektname>"
        return 1
    end

    if test -z "$name"
        echo "Please provide a project name."
        return 1
    end

    # Never create a project below a host or repository .config directory.
    set PROJECT_ROOT (pwd)
    set IN_CONFIG_DIR false
    if string match -q '*/.config' "$PROJECT_ROOT"
        set IN_CONFIG_DIR true
    end
    if string match -q '*/.config/*' "$PROJECT_ROOT"
        set IN_CONFIG_DIR true
    end
    if test "$IN_CONFIG_DIR" = true
        echo "❌ Refusing to create a project inside a .config directory."
        return 1
    end

    # ==================================================
    # Validate project name
    # ==================================================

    if not string match -rq '^[a-zA-Z0-9][a-zA-Z0-9_-]*$' "$name"

        echo ""
        echo "❌ Invalid project name:"
        echo "   $name"
        echo ""
        echo "Allowed characters:"
        echo "   letters, numbers, '-' and '_'"
        echo ""

        return 1
    end

    # ==================================================
    # Project paths
    # ==================================================

    set PROJECT_DIR "$PROJECT_ROOT/$name"

    set IMAGE_NAME "python-secure-dev-$name"
    set CONTAINER_NAME "$name"

    if test -d "$PROJECT_DIR"

        echo ""
        echo "❌ Folder '$name' already exists!"
        echo ""
        echo "Path:"
        echo "  $PROJECT_DIR"
        echo ""

        return 1
    end

    # ==================================================
    # Detect host UID/GID
    # ==================================================

    set HOST_UID (id -u)
    set HOST_GID (id -g)

    if test -z "$HOST_UID" -o -z "$HOST_GID"

        echo ""
        echo "❌ Could not determine host UID/GID."
        echo ""

        return 1
    end

    # ==================================================
    # Detect installed Python versions
    # ==================================================

    echo ""
    echo "Python version selection"
    echo ""
    echo "Detecting installed Python versions..."

    set PYTHON_CANDIDATES

    for PYTHON_BIN in /usr/bin/python3.*

        if test -x "$PYTHON_BIN"

            set BASENAME (basename "$PYTHON_BIN")

            if string match -rq '^python3\.[0-9]+$' "$BASENAME"

                set VERSION (
                    "$PYTHON_BIN" --version 2>&1 |
                    string replace 'Python ' ''
                )

                if test -n "$VERSION"

                    set MINOR_VERSION (
                        string replace -r '^3\.' '' "$VERSION" |
                        string split '.'
                    )[1]

                    set VERSION_SHORT "3.$MINOR_VERSION"

                    if test "$MINOR_VERSION" -ge 13

                        if not contains "$VERSION_SHORT" $PYTHON_CANDIDATES
                            set -a PYTHON_CANDIDATES "$VERSION_SHORT"
                        end

                    end
                end
            end
        end
    end

    # ==================================================
    # Fallback: python3
    # ==================================================

    if test (count $PYTHON_CANDIDATES) -eq 0

        if command -q python3

            set SYSTEM_PYTHON_VERSION (
                python3 --version 2>&1 |
                string replace 'Python ' ''
            )

            if string match -rq '^3\.[0-9]+' "$SYSTEM_PYTHON_VERSION"

                set MINOR_VERSION (
                    string replace -r '^3\.' '' "$SYSTEM_PYTHON_VERSION" |
                    string split '.'
                )[1]

                set VERSION_SHORT "3.$MINOR_VERSION"

                if test "$MINOR_VERSION" -ge 13
                    set -a PYTHON_CANDIDATES "$VERSION_SHORT"
                end
            end
        end
    end

    # ==================================================
    # No compatible Python
    # ==================================================

    if test (count $PYTHON_CANDIDATES) -eq 0

        echo ""
        echo "❌ No compatible Python 3.13+ versions were found."
        echo ""
        echo "Install/update Python with:"
        echo ""
        echo "  sudo pacman -S python"
        echo ""

        return 1
    end

    # ==================================================
    # Sort versions
    # ==================================================

    set PYTHON_CANDIDATES (
        printf '%s\n' $PYTHON_CANDIDATES |
        sort -V
    )

    set LATEST_PYTHON_VERSION $PYTHON_CANDIDATES[-1]

    # ==================================================
    # Show installed versions
    # ==================================================

    echo ""
    echo "Installed compatible Python versions:"
    echo ""

    set INDEX 1

    for VERSION in $PYTHON_CANDIDATES

        if test "$VERSION" = "$LATEST_PYTHON_VERSION"
            echo "  $INDEX) $VERSION  ← default"
        else
            echo "  $INDEX) $VERSION"
        end

        set INDEX (math $INDEX + 1)
    end

    echo ""
    echo "Latest installed Python: $LATEST_PYTHON_VERSION"
    echo ""

    # ==================================================
    # Ask for Python version
    # ==================================================

    read -P "Use latest version? [Y/n]: " USE_LATEST

    if test -z "$USE_LATEST"
        set USE_LATEST y
    end

    if string match -qi "y*" "$USE_LATEST"

        set PYTHON_VERSION "$LATEST_PYTHON_VERSION"

    else

        while true

            echo ""
            read -P "Enter Python version (e.g. 3.13): " PYTHON_VERSION

            if contains "$PYTHON_VERSION" $PYTHON_CANDIDATES
                break
            end

            echo ""
            echo "❌ Python $PYTHON_VERSION is not installed or not supported."
            echo ""
            echo "Available versions:"
            printf '  %s\n' $PYTHON_CANDIDATES
        end
    end

    # ==================================================
    # Find exact host Python binary
    # ==================================================

    set PYTHON_MINOR (
        string replace -r '^3\.' '' "$PYTHON_VERSION"
    )

    set HOST_PYTHON "/usr/bin/python3.$PYTHON_MINOR"

    if not test -x "$HOST_PYTHON"

        echo ""
        echo "❌ Could not find:"
        echo "   $HOST_PYTHON"
        echo ""

        return 1
    end

    set HOST_PYTHON_FULL_VERSION (
        "$HOST_PYTHON" --version 2>&1
    )

    echo ""
    echo "Selected Python:"
    echo "  $HOST_PYTHON_FULL_VERSION"
    echo "  Binary: $HOST_PYTHON"
    echo ""

    # ==================================================
    # Optional container Nerd Font
    #
    # IMPORTANT:
    # This is installed ONLY inside the Docker image.
    # Nothing is written to ~/.local/share/fonts.
    # ==================================================

    set INSTALL_NERD_FONT false

    read -P "Install JetBrains Mono Nerd Font inside the container? [y/N]: " NERD_FONT_ANSWER

    if string match -qi "y*" "$NERD_FONT_ANSWER"
        set INSTALL_NERD_FONT true
    end

    set INSTALL_NVIM false
    read -P "Install Neovim and copy host ~/.config/nvim into the container? [y/N]: " NVIM_ANSWER

    if string match -qi "y*" "$NVIM_ANSWER"
        set INSTALL_NVIM true
    end

    set HOST_NVIM_CONFIG "$HOME/.config/nvim"
    if test "$INSTALL_NVIM" = true; and not test -d "$HOST_NVIM_CONFIG"
        echo "❌ Host Neovim configuration not found: $HOST_NVIM_CONFIG"
        return 1
    end

    # ==================================================
    # Existing Docker container
    # ==================================================

    if sudo docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1

        echo ""
        echo "❌ Docker container '$CONTAINER_NAME' already exists."
        echo ""
        echo "Check it with:"
        echo "  sudo docker ps -a --filter name=$CONTAINER_NAME"
        echo ""
        echo "Remove it with:"
        echo "  sudo docker rm -f $CONTAINER_NAME"
        echo ""

        return 1
    end

    # ==================================================
    # Python package name
    # ==================================================

    set PACKAGE_NAME (
        string lower "$name" |
        string replace -a '-' '_'
    )

    set PACKAGE_NAME (
        string replace -ra '[^a-zA-Z0-9_]' '_' "$PACKAGE_NAME"
    )

    if string match -rq '^[0-9]' "$PACKAGE_NAME"
        set PACKAGE_NAME "_$PACKAGE_NAME"
    end

    # ==================================================
    # Create project directories
    # ==================================================

    echo ""
    echo "Creating project:"
    echo "  $PROJECT_DIR"
    echo ""

    mkdir -p \
        "$PROJECT_DIR/src/$PACKAGE_NAME" \
        "$PROJECT_DIR/tests" \
        "$PROJECT_DIR/.devcontainer/nvim"

    if test $status -ne 0

        echo ""
        echo "❌ Failed to create project directories."
        return 1
    end

    # ==================================================
    # Enter project directory
    # ==================================================

    pushd "$PROJECT_DIR" >/dev/null

    if test $status -ne 0

        echo ""
        echo "❌ Failed to enter project directory."
        return 1
    end

    # ==================================================
    # Create Python package files
    # ==================================================

    echo "\"\"\"$PACKAGE_NAME package.\"\"\"" >"src/$PACKAGE_NAME/__init__.py"

    printf '%s\n' \
        'def main() -> None:' \
        '    print("Hello, Python!")' \
        '' \
        'if __name__ == "__main__":' \
        '    main()' \
        >"src/$PACKAGE_NAME/main.py"

    printf '%s\n' \
        '"""Database related functionality."""' \
        '' \
        'def connect() -> str:' \
        '    """Return a placeholder database connection."""' \
        '    return "database connection"' \
        >"src/$PACKAGE_NAME/database.py"

    printf '%s\n' \
        '"""Utility functions."""' \
        '' \
        'def add(a: int, b: int) -> int:' \
        '    """Add two integers."""' \
        '    return a + b' \
        >"src/$PACKAGE_NAME/utils.py"

    # ==================================================
    # Tests
    # ==================================================

    printf '%s\n' \
        "from $PACKAGE_NAME.database import connect" \
        '' \
        'def test_connect():' \
        '    assert connect() == "database connection"' \
        >"tests/test_database.py"

    printf '%s\n' \
        "from $PACKAGE_NAME.utils import add" \
        '' \
        'def test_add():' \
        '    assert add(2, 3) == 5' \
        >"tests/test_utils.py"

    # ==================================================
    # pyproject.toml
    # ==================================================

    printf '%s\n' \
        '[build-system]' \
        'requires = ["hatchling"]' \
        'build-backend = "hatchling.build"' \
        '' \
        '[project]' \
        "name = \"$PACKAGE_NAME\"" \
        'version = "0.1.0"' \
        'description = "Python application"' \
        'readme = "README.md"' \
        "requires-python = \">=$PYTHON_VERSION\"" \
        'dependencies = []' \
        '' \
        '[dependency-groups]' \
        'dev = [' \
        '    "pytest",' \
        '    "black",' \
        '    "mypy",' \
        '    "bandit",' \
        '    "jupyter",' \
        '    "jupyterlab",' \
        '    "pyright",' \
        '    "ruff",' \
        ']' \
        '' \
        '[tool.pytest.ini_options]' \
        'testpaths = ["tests"]' \
        >pyproject.toml

    # ==================================================
    # README
    # ==================================================

    printf '%s\n' \
        "# $name" \
        '' \
        'Python application created with create-python-container-nvim.' \
        '' \
        '## Run' \
        '' \
        '```bash' \
        "python -m $PACKAGE_NAME.main" \
        '```' \
        '' \
        '## Tests' \
        '' \
        '```bash' \
        'pytest' \
        '```' \
        >README.md

    # ==================================================
    # Copy the host Neovim/LazyVim configuration into the build context.
    # The host directory is only read; it is never modified or mounted.
    # ==================================================

    if test "$INSTALL_NVIM" = true
        echo ""
        echo "Copying host Neovim/LazyVim configuration..."
        rm -rf "$PROJECT_DIR/.devcontainer/nvim"
        mkdir -p "$PROJECT_DIR/.devcontainer/nvim"
        cp -a "$HOST_NVIM_CONFIG/." "$PROJECT_DIR/.devcontainer/nvim/"

        if test $status -ne 0
            echo "❌ Failed to copy the host Neovim configuration."
            rm -rf "$PROJECT_DIR"
            return 1
        end
    end

    # ==================================================
    # Dockerfile
    # ==================================================

    echo ""
    echo "Creating Dockerfile..."

    printf '%s\n' \
        "FROM python:$PYTHON_VERSION-alpine" \
        '' \
        '# ==================================================' \
        '# Build arguments' \
        '# ==================================================' \
        '' \
        "ARG DEV_UID=$HOST_UID" \
        "ARG DEV_GID=$HOST_GID" \
        "ARG INSTALL_NVIM=$INSTALL_NVIM" \
        "ARG INSTALL_NERD_FONT=$INSTALL_NERD_FONT" \
        '' \
        '# ==================================================' \
        '# System packages' \
        '# ==================================================' \
        '' \
        "RUN apk add --no-cache \\" \
        "    fish \\" \
        "    git \\" \
        "    curl \\" \
        "    bash \\" \
        "    ca-certificates \\" \
        "    build-base \\" \
        "    gcc \\" \
        "    g++ \\" \
        "    clang \\" \
        "    time \\" \
        "    nodejs \\" \
        "    npm \\" \
        "    linux-headers \\" \
        "    libffi-dev \\" \
        "    openssl-dev \\" \
        "    ripgrep \\" \
        "    fd \\" \
        "    fontconfig \\" \
        '    unzip' \
        '' \
        '# ==================================================' \
        '# Optional Neovim' \
        '# ==================================================' \
        '' \
        'RUN if [ "$INSTALL_NVIM" = "true" ]; then apk add --no-cache neovim; fi' \
        '' \
        '# ==================================================' \
        '# Optional JetBrains Mono Nerd Font' \
        '' \
        '# Installed ONLY inside the container image.' \
        '# ==================================================' \
        '' \
        "RUN if [ \"\$INSTALL_NERD_FONT\" = \"true\" ]; then \\" \
        "      mkdir -p /usr/local/share/fonts/JetBrainsMono && \\" \
        "      curl -fL \\" \
        "        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \\" \
        "        -o /tmp/JetBrainsMono.zip && \\" \
        "      unzip -q /tmp/JetBrainsMono.zip \\" \
        "        -d /usr/local/share/fonts/JetBrainsMono && \\" \
        "      rm -f /tmp/JetBrainsMono.zip && \\" \
        "      fc-cache -f -v; \\" \
        '    fi' \
        '' \
        '# ==================================================' \
        '# Developer user' \
        '# ==================================================' \
        '' \
        "RUN addgroup -g \$DEV_GID developer && \\" \
        '    adduser -D -u $DEV_UID -G developer developer' \
        '' \
        '# ==================================================' \
        '# Python virtual environment' \
        '# ==================================================' \
        '' \
        "RUN mkdir -p /opt/venv && \\" \
        '    chown -R developer:developer /opt/venv' \
        '' \
        '# ==================================================' \
        '# Container-only Neovim directories' \
        '# ==================================================' \
        '' \
        "RUN mkdir -p /home/developer/.config/nvim && \\" \
        "    mkdir -p /home/developer/.local/share/nvim && \\" \
        "    mkdir -p /home/developer/.local/state/nvim && \\" \
        "    mkdir -p /home/developer/.cache/nvim && \\" \
        '    chown -R developer:developer /home/developer' \
        '' \
        '# ==================================================' \
        '# Copy LazyVim configuration into container' \
        '# ==================================================' \
        '' \
        "COPY --chown=developer:developer \\" \
        "    .devcontainer/nvim \\" \
        '    /home/developer/.config/nvim' \
        '' \
        '# ==================================================' \
        '# Environment' \
        '# ==================================================' \
        '' \
        'ENV HOME=/home/developer' \
        'ENV VIRTUAL_ENV=/opt/venv' \
        'ENV PATH=/opt/venv/bin:$PATH' \
        '' \
        '# ==================================================' \
        '# Workspace' \
        '# ==================================================' \
        '' \
        'WORKDIR /workspace' \
        '' \
        'USER developer' \
        '' \
        'CMD ["fish"]' \
        >Dockerfile

    set DEVCONTAINER_STATUS $status
    popd >/dev/null

    if test $DEVCONTAINER_STATUS -ne 0

        echo ""
        echo "❌ Failed to create Dockerfile."
        return 1
    end

    # ==================================================
    # Dev Container configuration
    # ==================================================

    printf '%s\n' \
        '{' \
        "  \"name\": \"$name\"," \
        '  "build": {' \
        '    "dockerfile": "../Dockerfile",' \
        '    "context": "..",' \
        '    "args": {' \
        "      \"DEV_UID\": \"$HOST_UID\"," \
        "      \"DEV_GID\": \"$HOST_GID\"," \
        "      \"INSTALL_NVIM\": \"$INSTALL_NVIM\"," \
        "      \"INSTALL_NERD_FONT\": \"$INSTALL_NERD_FONT\"" \
        '    }' \
        '  },' \
        '  "workspaceFolder": "/workspace",' \
        '  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind",' \
        '  "remoteUser": "developer",' \
        '  "containerUser": "developer",' \
        '  "overrideCommand": false' \
        '}' \
        >"$PROJECT_DIR/.devcontainer/devcontainer.json"

    if test $status -ne 0

        echo ""
        echo "❌ Failed to create devcontainer.json."
        return 1
    end

    # ==================================================
    # Docker build
    # ==================================================

    echo ""
    echo "🐳 Building secure Docker image..."
    echo ""
    echo "   Base image:"
    echo "   python:$PYTHON_VERSION-alpine"
    echo ""
    echo "   Host UID:"
    echo "   $HOST_UID"
    echo ""
    echo "   Host GID:"
    echo "   $HOST_GID"
    echo ""
    echo "   Neovim:"
    if test "$INSTALL_NVIM" = true
        echo "   enabled with copied host configuration"
    else
        echo "   disabled"
    end
    echo ""

    if test "$INSTALL_NERD_FONT" = true
        echo "   Nerd Font:"
        echo "   JetBrains Mono Nerd Font → container"
    else
        echo "   Nerd Font:"
        echo "   disabled"
    end

    echo ""

    sudo docker build \
        --pull \
        --build-arg DEV_UID="$HOST_UID" \
        --build-arg DEV_GID="$HOST_GID" \
        --build-arg INSTALL_NVIM="$INSTALL_NVIM" \
        --build-arg INSTALL_NERD_FONT="$INSTALL_NERD_FONT" \
        -t "$IMAGE_NAME" "$PROJECT_DIR"

    if test $status -ne 0

        echo ""
        echo "❌ Docker build failed!"
        return 1
    end

    # ==================================================
    # Start container
    # ==================================================

    echo ""
    echo "Starting secure container..."

    sudo docker run -dit \
        --name "$CONTAINER_NAME" \
        --hostname "$name" \
        --security-opt=no-new-privileges:true \
        --cap-drop=ALL \
        --memory="2g" \
        --cpus="2" \
        --mount "type=bind,source=$PROJECT_DIR,target=/workspace" \
        --workdir /workspace \
        "$IMAGE_NAME"

    if test $status -ne 0

        echo ""
        echo "❌ Failed to start container!"
        return 1
    end

    # ==================================================
    # Verify container user
    # ==================================================

    echo ""
    echo "Verifying container user..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        id

    if test $status -ne 0

        echo ""
        echo "❌ Could not verify container user!"
        return 1
    end

    # ==================================================
    # Verify workspace permissions
    # ==================================================

    echo ""
    echo "Verifying workspace permissions..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        sh -c 'touch /workspace/.container_write_test && rm /workspace/.container_write_test'

    if test $status -ne 0

        echo ""
        echo "❌ Container cannot write to /workspace!"
        return 1
    end

    echo "✅ /workspace is writable."

    # ==================================================
    # Verify container font
    # ==================================================

    if test "$INSTALL_NERD_FONT" = true

        echo ""
        echo "Verifying JetBrains Mono Nerd Font..."

        sudo docker exec \
            "$CONTAINER_NAME" \
            sh -c 'fc-list | grep -qi "JetBrains Mono"'

        if test $status -ne 0

            echo ""
            echo "⚠️ JetBrains Mono Nerd Font could not be verified."

        else

            echo "✅ JetBrains Mono Nerd Font is installed inside container."

        end
    end

    # ==================================================
    # Create Python virtual environment
    # ==================================================

    echo ""
    echo "Creating Python virtual environment..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        python -m venv /opt/venv

    if test $status -ne 0

        echo "❌ Failed to create virtual environment!"
        return 1
    end

    # ==================================================
    # Upgrade pip
    # ==================================================

    echo ""
    echo "Upgrading pip..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/python \
        -m pip install --upgrade pip

    if test $status -ne 0

        echo "❌ Failed to upgrade pip!"
        return 1
    end

    # ==================================================
    # Install uv
    # ==================================================

    echo ""
    echo "Installing uv..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/python \
        -m pip install --upgrade uv

    if test $status -ne 0

        echo "❌ Failed to install uv!"
        return 1
    end

    # ==================================================
    # Install build dependency
    # ==================================================

    echo ""
    echo "Installing hatchling..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/uv \
        pip install hatchling

    if test $status -ne 0

        echo "❌ Failed to install hatchling!"
        return 1
    end

    # ==================================================
    # Install Python development tools
    # ==================================================

    echo ""
    echo "Installing Python development tools..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/uv \
        pip install \
        pytest \
        black \
        mypy \
        bandit \
        jupyter \
        jupyterlab \
        pyright \
        ruff

    if test $status -ne 0

        echo "❌ Failed to install Python development tools!"
        return 1
    end

    # ==================================================
    # Install project
    # ==================================================

    echo ""
    echo "Installing project..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/uv \
        pip install \
        -e /workspace

    if test $status -ne 0

        echo "❌ Failed to install project!"
        return 1
    end

    # ==================================================
    # Initial tests
    # ==================================================

    echo ""
    echo "Running initial tests..."
    echo ""

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/pytest

    if test $status -ne 0

        echo ""
        echo "⚠️ Initial tests failed."

    else

        echo ""
        echo "✅ Initial tests passed!"

    end

    if test "$INSTALL_NVIM" = true

        # ==================================================
        # Verify Neovim
        # ==================================================

    echo ""
    echo "Verifying Neovim..."

    set NVIM_VERSION (
        sudo docker exec \
            "$CONTAINER_NAME" \
            nvim \
            --version |
        head -n 1
    )

    echo "  $NVIM_VERSION"

    # ==================================================
    # Verify container-only Neovim configuration
    # ==================================================

    echo ""
    echo "Verifying container Neovim configuration..."

        sudo docker exec \
            "$CONTAINER_NAME" \
            sh -c 'test -d /home/developer/.config/nvim'

        if test $status -ne 0

            echo ""
            echo "❌ Neovim configuration was not copied into container."
            return 1
        end

        echo "✅ Neovim configuration exists inside container."

        # Initialize the copied LazyVim configuration inside the container.
        echo ""
        echo "Initializing LazyVim inside container..."
        echo ""

        sudo docker exec \
            "$CONTAINER_NAME" \
            nvim \
            --headless \
            "+Lazy! sync" \
            "+qa"

        if test $status -ne 0

            echo ""
            echo "❌ LazyVim initialization failed."
            return 1
        end

        echo ""
        echo "✅ LazyVim initialized inside container."
    end

    # ==================================================
    # Verify Python tooling
    # ==================================================

    echo ""
    echo "Verifying Python tooling..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/python \
        --version

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/ruff \
        --version

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/pyright \
        --version

    echo ""
    echo "✅ Python tooling is available inside container."

    # ==================================================
    # Get actual versions
    # ==================================================

    set ACTUAL_PYTHON_VERSION (
        sudo docker exec \
            "$CONTAINER_NAME" \
            /opt/venv/bin/python \
            --version
    )

    set UV_VERSION (
        sudo docker exec \
            "$CONTAINER_NAME" \
            /opt/venv/bin/uv \
            --version
    )

    set CONTAINER_USER (
        sudo docker exec \
            "$CONTAINER_NAME" \
            id -un
    )

    # ==================================================
    # Final output
    # ==================================================

    echo ""
    echo "========================================"
    echo " Secure Python project created!"
    echo "========================================"
    echo ""
    echo "Project:"
    echo "  $PROJECT_DIR"
    echo ""
    echo "Package:"
    echo "  $PACKAGE_NAME"
    echo ""
    echo "Python selected:"
    echo "  $PYTHON_VERSION"
    echo ""
    echo "Python actual:"
    echo "  $ACTUAL_PYTHON_VERSION"
    echo ""
    echo "uv:"
    echo "  $UV_VERSION"
    echo ""
    if test "$INSTALL_NVIM" = true
        echo "Neovim:"
        echo "  $NVIM_VERSION"
        echo ""
        echo "Neovim configuration:"
        echo "  copied from $HOST_NVIM_CONFIG"
        echo "  /home/developer/.config/nvim"
        echo ""
    else
        echo "Neovim:"
        echo "  disabled"
        echo ""
    end
    echo "Container:"
    echo "  $CONTAINER_NAME"
    echo ""
    echo "Container user:"
    echo "  $CONTAINER_USER"
    echo ""
    echo "Virtual environment:"
    echo "  /opt/venv"
    echo ""
    if test "$INSTALL_NVIM" = true
        echo "LazyVim:"
        echo "  copied and initialized inside container"
    end
    echo ""
    echo "Python tooling:"
    echo "  Pyright"
    echo "  Ruff"
    echo "  Black"
    echo "  mypy"
    echo "  Bandit"
    echo ""
    if test "$INSTALL_NVIM" = true
        echo "Python LazyVim:"
        echo "  provided by copied host configuration"
        echo ""
    end

    if test "$INSTALL_NERD_FONT" = true
        echo "JetBrains Mono Nerd Font:"
        echo "  Installed inside container"
    else
        echo "JetBrains Mono Nerd Font:"
        echo "  Not installed"
    end

    echo ""
    echo "Host Neovim:"
    if test "$INSTALL_NVIM" = true
        echo "  Read only for copying; not modified"
    else
        echo "  Not accessed"
    end
    echo ""
    echo "Host fonts:"
    echo "  NOT MODIFIED"
    echo ""
    echo "Enter container:"
    echo "  sudo docker exec -it $CONTAINER_NAME fish"
    echo ""
    if test "$INSTALL_NVIM" = true
        echo "Open Neovim inside container:"
        echo "  sudo docker exec -it $CONTAINER_NAME nvim ."
        echo ""
    end
    echo "Run application:"
    echo "  python -m $PACKAGE_NAME.main"
    echo ""
    echo "Run tests:"
    echo "  pytest"
    echo ""
    echo "Format:"
    echo "  black src tests"
    echo ""
    echo "Type check:"
    echo "  mypy src"
    echo ""
    echo "Lint:"
    echo "  ruff check src tests"
    echo ""
    echo "Security:"
    echo "  bandit -r src"
    echo ""
    echo "Jupyter:"
    echo "  jupyter lab --ip=0.0.0.0 --port=8888 --no-browser"
    echo ""
    echo "Stop:"
    echo "  sudo docker stop $CONTAINER_NAME"
    echo ""
    echo "Remove:"
    echo "  sudo docker rm -f $CONTAINER_NAME"
    echo ""
    echo "Image:"
    echo "  sudo docker rmi $IMAGE_NAME"
    echo ""
    echo "========================================"
    echo " Done!"
    echo "========================================"
    echo ""

end
