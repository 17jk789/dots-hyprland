function create-python-container --description "Create a secure Python development container with automatic Python version selection and uv" --argument-names action name

    # ==================================================
    # Arguments
    # ==================================================

    if test "$action" != new
        echo "Usage:"
        echo "  create-python-container new <projektname>"
        return 1
    end

    if test -z "$name"
        echo "Please provide a project name."
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
    # Detect installed Python versions on Arch host
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

                    # Only Python 3.13+
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
    # No compatible Python found
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
    # Ask for version
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

    # ==================================================
    # Show selected Python
    # ==================================================

    set HOST_PYTHON_FULL_VERSION (
        "$HOST_PYTHON" --version 2>&1
    )

    echo ""
    echo "Selected Python:"
    echo "  $HOST_PYTHON_FULL_VERSION"
    echo "  Binary: $HOST_PYTHON"
    echo ""

    # ==================================================
    # Project configuration
    # ==================================================

    set PROJECT_DIR (pwd)/$name
    set IMAGE_NAME "python-secure-dev-$name"
    set CONTAINER_NAME "$name"

    if test -d "$PROJECT_DIR"

        echo "❌ Folder '$name' already exists!"
        return 1

    end

    # ==================================================
    # Check for existing Docker container
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

    mkdir -p \
        "$PROJECT_DIR/src/$PACKAGE_NAME" \
        "$PROJECT_DIR/tests" \
        "$PROJECT_DIR/.devcontainer"

    if test $status -ne 0

        echo "❌ Failed to create project directories!"
        return 1

    end

    cd "$PROJECT_DIR"

    # ==================================================
    # Create Python package files
    # ==================================================

    touch \
        "src/$PACKAGE_NAME/__init__.py" \
        "src/$PACKAGE_NAME/main.py" \
        "src/$PACKAGE_NAME/database.py" \
        "src/$PACKAGE_NAME/utils.py" \
        "tests/test_database.py" \
        "tests/test_utils.py" \
        pyproject.toml \
        README.md

    # ==================================================
    # __init__.py
    # ==================================================

    echo "\"\"\"$PACKAGE_NAME package.\"\"\"" >"src/$PACKAGE_NAME/__init__.py"

    # ==================================================
    # main.py
    # ==================================================

    echo 'def main() -> None:' >"src/$PACKAGE_NAME/main.py"
    echo '    print("Hello, Python!")' >>"src/$PACKAGE_NAME/main.py"
    echo "" >>"src/$PACKAGE_NAME/main.py"
    echo 'if __name__ == "__main__":' >>"src/$PACKAGE_NAME/main.py"
    echo '    main()' >>"src/$PACKAGE_NAME/main.py"

    # ==================================================
    # database.py
    # ==================================================

    echo '"""Database related functionality."""' >"src/$PACKAGE_NAME/database.py"
    echo "" >>"src/$PACKAGE_NAME/database.py"
    echo 'def connect() -> str:' >>"src/$PACKAGE_NAME/database.py"
    echo '    """Return a placeholder database connection."""' >>"src/$PACKAGE_NAME/database.py"
    echo '    return "database connection"' >>"src/$PACKAGE_NAME/database.py"

    # ==================================================
    # utils.py
    # ==================================================

    echo '"""Utility functions."""' >"src/$PACKAGE_NAME/utils.py"
    echo "" >>"src/$PACKAGE_NAME/utils.py"
    echo 'def add(a: int, b: int) -> int:' >>"src/$PACKAGE_NAME/utils.py"
    echo '    """Add two integers."""' >>"src/$PACKAGE_NAME/utils.py"
    echo '    return a + b' >>"src/$PACKAGE_NAME/utils.py"

    # ==================================================
    # Tests
    # ==================================================

    echo "from $PACKAGE_NAME.database import connect" >"tests/test_database.py"
    echo "" >>"tests/test_database.py"
    echo "def test_connect():" >>"tests/test_database.py"
    echo '    assert connect() == "database connection"' >>"tests/test_database.py"

    echo "from $PACKAGE_NAME.utils import add" >"tests/test_utils.py"
    echo "" >>"tests/test_utils.py"
    echo "def test_add():" >>"tests/test_utils.py"
    echo "    assert add(2, 3) == 5" >>"tests/test_utils.py"

    # ==================================================
    # pyproject.toml
    # ==================================================

    echo "[build-system]" >pyproject.toml
    echo 'requires = ["hatchling"]' >>pyproject.toml
    echo 'build-backend = "hatchling.build"' >>pyproject.toml

    echo "" >>pyproject.toml

    echo "[project]" >>pyproject.toml
    echo "name = \"$PACKAGE_NAME\"" >>pyproject.toml
    echo 'version = "0.1.0"' >>pyproject.toml
    echo 'description = "Python application"' >>pyproject.toml
    echo 'readme = "README.md"' >>pyproject.toml
    echo "requires-python = \">=$PYTHON_VERSION\"" >>pyproject.toml
    echo 'dependencies = []' >>pyproject.toml

    echo "" >>pyproject.toml

    echo "[dependency-groups]" >>pyproject.toml
    echo 'dev = [' >>pyproject.toml
    echo '    "pytest",' >>pyproject.toml
    echo '    "black",' >>pyproject.toml
    echo '    "mypy",' >>pyproject.toml
    echo '    "bandit",' >>pyproject.toml
    echo '    "jupyter",' >>pyproject.toml
    echo '    "jupyterlab",' >>pyproject.toml
    echo ']' >>pyproject.toml

    echo "" >>pyproject.toml

    echo "[tool.pytest.ini_options]" >>pyproject.toml
    echo 'testpaths = ["tests"]' >>pyproject.toml

    # ==================================================
    # README
    # ==================================================

    echo "# $name" >README.md
    echo "" >>README.md
    echo "Python application created with create-python-container." >>README.md
    echo "" >>README.md
    echo "## Run" >>README.md
    echo "" >>README.md
    echo '```bash' >>README.md
    echo "python -m $PACKAGE_NAME.main" >>README.md
    echo '```' >>README.md
    echo "" >>README.md
    echo "## Tests" >>README.md
    echo "" >>README.md
    echo '```bash' >>README.md
    echo "pytest" >>README.md
    echo '```' >>README.md

    # ==================================================
    # Dockerfile
    # ==================================================

    echo "FROM python:$PYTHON_VERSION-alpine" >Dockerfile

    echo "" >>Dockerfile

    echo "# ================================================" >>Dockerfile
    echo "# Build and development tools" >>Dockerfile
    echo "# ================================================" >>Dockerfile

    echo "RUN apk add --no-cache \\" >>Dockerfile
    echo "    fish \\" >>Dockerfile
    echo "    git \\" >>Dockerfile
    echo "    curl \\" >>Dockerfile
    echo "    bash \\" >>Dockerfile
    echo "    build-base \\" >>Dockerfile
    echo "    gcc \\" >>Dockerfile
    echo "    g++ \\" >>Dockerfile
    echo "    clang \\" >>Dockerfile
    echo "    openjdk21 \\" >>Dockerfile
    echo "    time \\" >>Dockerfile
    echo "    neovim \\" >>Dockerfile
    echo "    linux-headers \\" >>Dockerfile
    echo "    libffi-dev \\" >>Dockerfile
    echo "    openssl-dev" >>Dockerfile

    echo "" >>Dockerfile

    echo "# ================================================" >>Dockerfile
    echo "# Host UID/GID" >>Dockerfile
    echo "# ================================================" >>Dockerfile

    echo "ARG DEV_UID=$HOST_UID" >>Dockerfile
    echo "ARG DEV_GID=$HOST_GID" >>Dockerfile

    echo "" >>Dockerfile

    echo "# ================================================" >>Dockerfile
    echo "# Non-root developer" >>Dockerfile
    echo "# ================================================" >>Dockerfile

    echo 'RUN addgroup -g $DEV_GID developer && \\' >>Dockerfile
    echo '    adduser -D -u $DEV_UID -G developer developer' >>Dockerfile

    echo "" >>Dockerfile

    echo "# ================================================" >>Dockerfile
    echo "# Virtual environment outside /workspace" >>Dockerfile
    echo "# ================================================" >>Dockerfile

    echo "RUN mkdir -p /opt/venv && \\" >>Dockerfile
    echo "    chown -R developer:developer /opt/venv" >>Dockerfile

    echo "" >>Dockerfile

    echo "ENV VIRTUAL_ENV=/opt/venv" >>Dockerfile
    echo 'ENV PATH=/opt/venv/bin:$PATH' >>Dockerfile

    echo "" >>Dockerfile

    echo "# ================================================" >>Dockerfile
    echo "# Workspace" >>Dockerfile
    echo "# ================================================" >>Dockerfile

    echo "WORKDIR /workspace" >>Dockerfile

    echo "" >>Dockerfile

    echo "USER developer" >>Dockerfile

    echo "" >>Dockerfile

    echo 'CMD ["fish"]' >>Dockerfile

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
        "      \"DEV_GID\": \"$HOST_GID\"" \
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
        echo "❌ Failed to create .devcontainer/devcontainer.json!"
        return 1

    end

    # ==================================================
    # Build image
    # ==================================================

    echo ""
    echo "🐳 Building secure Docker image..."
    echo ""
    echo "   Base image:"
    echo "   python:$PYTHON_VERSION-alpine"
    echo ""
    echo "   Host UID: $HOST_UID"
    echo "   Host GID: $HOST_GID"
    echo ""

    sudo docker build \
        --pull \
        --build-arg DEV_UID="$HOST_UID" \
        --build-arg DEV_GID="$HOST_GID" \
        -t "$IMAGE_NAME" .

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
        echo ""
        echo "Host UID/GID:"
        echo "  UID: $HOST_UID"
        echo "  GID: $HOST_GID"
        echo ""

        return 1
    end

    echo "✅ /workspace is writable."

    # ==================================================
    # Create virtual environment
    # ==================================================

    echo ""
    echo "Creating Python virtual environment..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        python -m venv /opt/venv

    if test $status -ne 0

        echo ""
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

        echo ""
        echo "❌ Failed to upgrade pip!"
        return 1

    end

    # ==================================================
    # Install uv
    # ==================================================

    echo ""
    echo "Installing uv via pip..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/python \
        -m pip install --upgrade uv

    if test $status -ne 0

        echo ""
        echo "❌ Failed to install uv!"
        return 1

    end

    # ==================================================
    # Install build dependency
    # ==================================================

    echo ""
    echo "Installing project build dependency..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/uv \
        pip install \
        hatchling

    if test $status -ne 0

        echo ""
        echo "❌ Failed to install hatchling!"
        return 1

    end

    # ==================================================
    # Install development tools
    # ==================================================

    echo ""
    echo "Installing development tools..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/uv \
        pip install \
        pytest \
        black \
        mypy \
        bandit \
        jupyter \
        jupyterlab

    if test $status -ne 0

        echo ""
        echo "❌ Failed to install development tools!"
        return 1

    end

    # ==================================================
    # Install project itself
    # ==================================================

    echo ""
    echo "Installing project..."

    sudo docker exec \
        "$CONTAINER_NAME" \
        /opt/venv/bin/uv \
        pip install \
        -e /workspace

    if test $status -ne 0

        echo ""
        echo "❌ Failed to install project!"
        return 1

    end

    # ==================================================
    # Run tests
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
        echo ""

    else

        echo ""
        echo "✅ Initial tests passed!"

    end

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
    echo "Project:          $name"
    echo "Package:          $PACKAGE_NAME"
    echo "Python selected:  $PYTHON_VERSION"
    echo "Python actual:    $ACTUAL_PYTHON_VERSION"
    echo "uv:               $UV_VERSION"
    echo "Container:        $CONTAINER_NAME"
    echo "Container user:   $CONTAINER_USER"
    echo "Host UID:         $HOST_UID"
    echo "Host GID:         $HOST_GID"
    echo "Virtual env:      /opt/venv"
    echo ""
    echo "Project structure:"
    echo ""
    echo "$name/"
    echo "├── .devcontainer/"
    echo "│   └── devcontainer.json"
    echo "├── src/"
    echo "│   └── $PACKAGE_NAME/"
    echo "│       ├── __init__.py"
    echo "│       ├── main.py"
    echo "│       ├── database.py"
    echo "│       └── utils.py"
    echo "├── tests/"
    echo "│   ├── test_database.py"
    echo "│   └── test_utils.py"
    echo "├── pyproject.toml"
    echo "├── README.md"
    echo "└── Dockerfile"
    echo ""
    echo "Enter container:"
    echo "  sudo docker exec -it $CONTAINER_NAME fish"
    echo ""
    echo "Run application:"
    echo "  python -m $PACKAGE_NAME.main"
    echo ""
    echo "Run tests:"
    echo "  pytest"
    echo ""
    echo "Format code:"
    echo "  black src tests"
    echo ""
    echo "Type check:"
    echo "  mypy src"
    echo ""
    echo "Security check:"
    echo "  bandit -r src"
    echo ""
    echo "Check Python:"
    echo "  python --version"
    echo ""
    echo "Check uv:"
    echo "  uv --version"
    echo ""
    echo "Add dependency:"
    echo "  uv add <package>"
    echo ""
    echo "Jupyter:"
    echo "  jupyter lab --ip=0.0.0.0 --port=8888 --no-browser"
    echo ""
    echo "Stop container:"
    echo "  sudo docker stop $CONTAINER_NAME"
    echo ""
    echo "Remove container:"
    echo "  sudo docker rm -f $CONTAINER_NAME"
    echo ""
    echo "Open with Neovim:"
    echo "  cd $PROJECT_DIR"
    echo "  nvim ."
    echo ""
    echo "Done!"

end
