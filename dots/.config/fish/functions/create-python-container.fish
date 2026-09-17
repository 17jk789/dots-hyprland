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

                    if not contains "$VERSION_SHORT" $PYTHON_CANDIDATES
                        set -a PYTHON_CANDIDATES "$VERSION_SHORT"
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

                set -a PYTHON_CANDIDATES "$VERSION_SHORT"

            end
        end
    end

    # ==================================================
    # No Python found
    # ==================================================

    if test (count $PYTHON_CANDIDATES) -eq 0

        echo ""
        echo "❌ No Python 3 versions were found."
        echo ""
        echo "Install Python with pacman:"
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
    echo "Installed Python versions:"
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
            echo "❌ Python $PYTHON_VERSION is not installed."
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
    set IMAGE_NAME python-secure-dev
    set CONTAINER_NAME "$name"

    if test -d "$PROJECT_DIR"

        echo "❌ Folder '$name' already exists!"
        return 1

    end

    # ==================================================
    # Python package name
    #
    # Docker/project names may contain "-"
    # Python packages should use "_"
    # ==================================================

    set PACKAGE_NAME (
        string lower "$name" |
        string replace -a '-' '_'
    )

    # Remove characters that are invalid for Python packages
    set PACKAGE_NAME (
        string replace -ra '[^a-zA-Z0-9_]' '_' "$PACKAGE_NAME"
    )

    # ==================================================
    # Create project directories
    # ==================================================

    mkdir -p \
        "$PROJECT_DIR/src/$PACKAGE_NAME" \
        "$PROJECT_DIR/tests"

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
    # Python package: __init__.py
    # ==================================================

    echo "\"\"\"$PACKAGE_NAME package.\"\"\"" >"src/$PACKAGE_NAME/__init__.py"

    # ==================================================
    # Python package: main.py
    # ==================================================

    echo 'def main() -> None:' >"src/$PACKAGE_NAME/main.py"

    echo '    print("Hello, Python!")' >>"src/$PACKAGE_NAME/main.py"

    echo "" >>"src/$PACKAGE_NAME/main.py"

    echo 'if __name__ == "__main__":' >>"src/$PACKAGE_NAME/main.py"

    echo '    main()' >>"src/$PACKAGE_NAME/main.py"

    # ==================================================
    # Python package: database.py
    # ==================================================

    echo '"""Database related functionality."""' >"src/$PACKAGE_NAME/database.py"

    echo "" >>"src/$PACKAGE_NAME/database.py"

    echo "" >>"src/$PACKAGE_NAME/database.py"

    echo 'def connect() -> str:' >>"src/$PACKAGE_NAME/database.py"

    echo '    """Return a placeholder database connection."""' >>"src/$PACKAGE_NAME/database.py"

    echo '    return "database connection"' >>"src/$PACKAGE_NAME/database.py"

    # ==================================================
    # Python package: utils.py
    # ==================================================

    echo '"""Utility functions."""' >"src/$PACKAGE_NAME/utils.py"

    echo "" >>"src/$PACKAGE_NAME/utils.py"

    echo "" >>"src/$PACKAGE_NAME/utils.py"

    echo 'def add(a: int, b: int) -> int:' >>"src/$PACKAGE_NAME/utils.py"

    echo '    """Add two integers."""' >>"src/$PACKAGE_NAME/utils.py"

    echo '    return a + b' >>"src/$PACKAGE_NAME/utils.py"

    # ==================================================
    # Tests
    # ==================================================

    echo "from $PACKAGE_NAME.database import connect" >"tests/test_database.py"

    echo "" >>"tests/test_database.py"

    echo "" >>"tests/test_database.py"

    echo "def test_connect():" >>"tests/test_database.py"

    echo '    assert connect() == "database connection"' >>"tests/test_database.py"

    echo "from $PACKAGE_NAME.utils import add" >"tests/test_utils.py"

    echo "" >>"tests/test_utils.py"

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
    echo 'requires-python = ">=3.13"' >>pyproject.toml
    echo 'dependencies = []' >>pyproject.toml

    echo "" >>pyproject.toml

    echo "[dependency-groups]" >>pyproject.toml
    echo 'dev = [' >>pyproject.toml
    echo '    "pytest",' >>pyproject.toml
    echo '    "black",' >>pyproject.toml
    echo '    "mypy",' >>pyproject.toml
    echo '    "bandit",' >>pyproject.toml
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
    echo pytest >>README.md
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
    echo "# Non-root developer" >>Dockerfile
    echo "# ================================================" >>Dockerfile

    echo "RUN adduser -D developer" >>Dockerfile

    echo "" >>Dockerfile

    echo "USER developer" >>Dockerfile

    echo "" >>Dockerfile

    echo "WORKDIR /workspace" >>Dockerfile

    echo "" >>Dockerfile

    echo "# ================================================" >>Dockerfile
    echo "# Virtual environment" >>Dockerfile
    echo "# ================================================" >>Dockerfile

    echo 'ENV VIRTUAL_ENV="/workspace/venv"' >>Dockerfile
    echo 'ENV PATH="/workspace/venv/bin:$PATH"' >>Dockerfile

    echo "" >>Dockerfile

    echo 'CMD ["fish"]' >>Dockerfile

    # ==================================================
    # Build image
    # ==================================================

    echo ""
    echo "🐳 Building secure Docker image..."
    echo ""
    echo "   Base image:"
    echo "   python:$PYTHON_VERSION-alpine"
    echo ""

    sudo docker build \
        --pull \
        -t $IMAGE_NAME .

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
        --name $CONTAINER_NAME \
        --hostname $name \
        --security-opt=no-new-privileges:true \
        --cap-drop=ALL \
        --memory="2g" \
        --cpus="2" \
        -v "$PROJECT_DIR":/workspace \
        -w /workspace \
        $IMAGE_NAME

    if test $status -ne 0

        echo ""
        echo "❌ Failed to start container!"
        return 1

    end

    # ==================================================
    # Create virtual environment
    # ==================================================

    echo ""
    echo "Creating Python virtual environment..."

    sudo docker exec \
        $CONTAINER_NAME \
        python -m venv /workspace/venv

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
        $CONTAINER_NAME \
        /workspace/venv/bin/python \
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
        $CONTAINER_NAME \
        /workspace/venv/bin/python \
        -m pip install --upgrade uv

    if test $status -ne 0

        echo ""
        echo "❌ Failed to install uv!"
        return 1

    end

    # ==================================================
    # Install project dependencies
    # ==================================================

    echo ""
    echo "Installing project dependencies with uv..."

    sudo docker exec \
        $CONTAINER_NAME \
        /workspace/venv/bin/uv \
        pip install \
        hatchling

    if test $status -ne 0

        echo ""
        echo "❌ Failed to install project dependencies!"
        return 1

    end

    # ==================================================
    # Install development dependencies
    # ==================================================

    echo ""
    echo "Installing development tools..."

    sudo docker exec \
        $CONTAINER_NAME \
        /workspace/venv/bin/uv \
        pip install \
        pytest \
        black \
        mypy \
        bandit

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
        $CONTAINER_NAME \
        /workspace/venv/bin/uv \
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
        $CONTAINER_NAME \
        /workspace/venv/bin/pytest

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
            $CONTAINER_NAME \
            /workspace/venv/bin/python \
            --version
    )

    set UV_VERSION (
        sudo docker exec \
            $CONTAINER_NAME \
            /workspace/venv/bin/uv \
            --version
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
    echo ""
    echo "Project structure:"
    echo ""
    echo "$name/"
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
    echo "Stop container:"
    echo "  sudo docker stop $CONTAINER_NAME"
    echo ""
    echo "Remove container:"
    echo "  sudo docker rm -f $CONTAINER_NAME"
    echo ""
    echo "Done!"

end
