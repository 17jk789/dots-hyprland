function create-python-jup-pro-container --argument-names action name
    if test "$action" != "new"
        echo "Usage:"
        echo "  create-python-jup-pro-container new <projektname>"
        return 1
    end

    if test -z "$name"
        echo "❌ Please provide a project name."
        return 1
    end

    set PROJECT_NAME $name
    set PROJECT_DIR (pwd)/$PROJECT_NAME
    set IMAGE_NAME "python-jupyter-secure"
    set CONTAINER_NAME "$name"

    if test -d "$PROJECT_DIR"
        echo "❌ Error: The folder '$PROJECT_NAME' already exists!"
        return 1
    end

    mkdir -p \
        "$PROJECT_DIR/src" \
        "$PROJECT_DIR/tests" \
        "$PROJECT_DIR/notebooks" \
        "$PROJECT_DIR/data"

    cd "$PROJECT_DIR"

    touch \
        main.py \
        requirements.txt \
        README.md \
        .gitignore

    echo "venv/" >> .gitignore
    echo "__pycache__/" >> .gitignore
    echo "*.pyc" >> .gitignore
    echo ".ipynb_checkpoints/" >> .gitignore

    echo 'print("🚀 Jupyter Container Ready!")' > main.py

    echo "FROM python:3.12-alpine" > Dockerfile

    echo "" >> Dockerfile
    echo "RUN apk add --no-cache \\" >> Dockerfile
    echo "    fish \\" >> Dockerfile
    echo "    git \\" >> Dockerfile
    echo "    curl \\" >> Dockerfile
    echo "    bash \\" >> Dockerfile
    echo "    gcc \\" >> Dockerfile
    echo "    musl-dev \\" >> Dockerfile
    echo "    linux-headers" >> Dockerfile

    echo "" >> Dockerfile
    echo "RUN adduser -D developer" >> Dockerfile

    echo "" >> Dockerfile
    echo "USER developer" >> Dockerfile

    echo "" >> Dockerfile
    echo "WORKDIR /workspace" >> Dockerfile

    echo "" >> Dockerfile
    echo 'ENV PATH="/workspace/venv/bin:$PATH"' >> Dockerfile

    echo "" >> Dockerfile
    echo 'CMD ["fish"]' >> Dockerfile

    echo "🐳 Building image..."

    sudo docker build -t $IMAGE_NAME .

    if test $status -ne 0
        echo "❌ Docker build failed!"
        return 1
    end

    echo "🚀 Starting container..."

    sudo docker run -dit \
        --name $CONTAINER_NAME \
        --hostname $PROJECT_NAME \
        --security-opt=no-new-privileges:true \
        --cap-drop=ALL \
        --memory="4g" \
        --cpus="2" \
        -p 8888:8888 \
        -v "$PROJECT_DIR":/workspace \
        -w /workspace \
        $IMAGE_NAME

    if test $status -ne 0
        echo "❌ Failed to start container!"
        return 1
    end

    sudo docker exec $CONTAINER_NAME python -m venv /workspace/venv

    sudo docker exec $CONTAINER_NAME fish -c "
        source /workspace/venv/bin/activate.fish;

        python -m pip install --upgrade pip;

        python -m pip install \
            pynvim \
            jupyter_client \
            ipykernel \
            pylatexenc \
            jupytext \
            nbformat \
            nbconvert \
            notebook \
            bandit \
            requests \
            black \
            mypy \
            pytest;

        python -m ipykernel install \
            --sys-prefix \
            --name="$PROJECT_NAME" \
            --display-name="Python ($PROJECT_NAME)"
    "

    echo ""
    echo "✅ Jupyter Docker project created!"
    echo ""
    echo "📁 Project: $PROJECT_NAME"
    echo "🐳 Container: $CONTAINER_NAME"
    echo ""
    echo "👉 Enter:"
    echo "   sudo docker exec -it $CONTAINER_NAME fish"
    echo ""
    echo "👉 Activate venv:"
    echo "   source venv/bin/activate.fish"
    echo ""
    echo "👉 Jupyter start:"
    echo "   jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser"
    echo ""
    echo "👉 Browser:"
    echo "   http://localhost:8888"
    echo ""
    echo "🛑 Stop container:"
    echo "   sudo docker stop $CONTAINER_NAME"
    echo ""
    echo "🔥 Done!"
end
