function create-python-pro --argument-names action name
    if test "$action" != "new"; or test -z "$name"
        echo "Usage: create-python-pro new <projektname>"
        return 1
    end

    set PROJECT_DIR (pwd)/$name

    if test -d "$PROJECT_DIR"
        echo "❌ Error: The folder $name already exists here!"
        return 1
    end

    mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/tests"
    cd "$PROJECT_DIR"

    python3 -m venv venv

    touch main.py

    source venv/bin/activate.fish

    python -m pip install --upgrade pip

    python -m pip install bandit black mypy pytest

    echo "✅ Project $name has been created!"
    echo "💡 Virtual environment is active. (Deactivate with ‘deactivate’)"
end
