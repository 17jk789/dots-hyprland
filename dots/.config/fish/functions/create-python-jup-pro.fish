function create-python-jup-pro --argument-names action name

    if test "$action" != "new" -o -z "$name"
        echo "Usage: create-python-jup-pro new <projektname>"
        return 1
    end

    set PROJECT_NAME $name
    set PROJECT_DIR (pwd)/$PROJECT_NAME

    if test -d "$PROJECT_DIR"
        echo "❌ Error: The $PROJECT_NAME folder already exists here!"
        return 1
    end

    mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/tests"
    cd "$PROJECT_DIR"

    python3.12 -m venv venv

    touch main.py

    source venv/bin/activate.fish

    python -m pip install --upgrade pip

    python -m pip install \
        pynvim jupyter_client ipykernel pylatexenc jupytext \
        nbformat nbconvert notebook \
        bandit black mypy pytest

    python -m ipykernel install --user \
        --name=$PROJECT_NAME \
        --display-name="Python ($PROJECT_NAME)"

    sudo chown -R $USER:$USER "$HOME/.local/share/jupyter"
    mkdir -p "$HOME/.local/share/jupyter/runtime"
    chmod -R 700 "$HOME/.local/share/jupyter/runtime"

    echo "✅ Project $PROJECT_NAME created."
    echo "💡 The virtual environment is active. Use 'deactivate' to exit."
end
