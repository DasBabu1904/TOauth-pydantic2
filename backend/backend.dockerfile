FROM tiangolo/uvicorn-gunicorn-fastapi:python3.7

WORKDIR /app/

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

    # Install Poetry
RUN pip install --upgrade pip
RUN pip install poetry==1.5.0
RUN poetry config virtualenvs.create false

# RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python && \
#     cd /usr/local/bin && \
#     ln -s /opt/poetry/bin/poetry && \
#     poetry config virtualenvs.create false

# Copy poetry.lock* in case it doesn't exist in the repo
COPY ./app/pyproject.toml ./app/poetry.lock* /app/

# Allow installing dev dependencies to run tests
ARG INSTALL_DEV=false
RUN bash -c "if [ $INSTALL_DEV == 'true' ] ; then poetry install --no-root ; else poetry install --no-root --no-dev ; fi"

# For development, Jupyter remote kernel, Hydrogen
# Using inside the container:
# jupyter lab --ip=0.0.0.0 --allow-root --NotebookApp.custom_display_url=http://127.0.0.1:8888
ARG INSTALL_JUPYTER=false
RUN bash -c "if [ $INSTALL_JUPYTER == 'true' ] ; then pip install jupyterlab ; fi"

COPY ./app /app
ENV PYTHONPATH=/app

RUN python3.7 -m pip install importlib-metadata==4.13.0
RUN python3.7 -m pip install httpcore==0.15