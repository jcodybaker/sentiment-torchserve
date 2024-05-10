FROM pytorch/torchserve:latest-cpu AS modelbuild

ADD --chown=model-server https://huggingface.co/cardiffnlp/twitter-roberta-base-sentiment-latest/resolve/main/pytorch_model.bin ./

ADD --chown=model-server https://raw.githubusercontent.com/pytorch/serve/master/examples/Huggingface_Transformers/Transformer_handler_generalized.py ./

COPY --chown=model-server config.json setup_config.json index_to_name.json ./

RUN torch-model-archiver \
    --model-name=twitter-roberta-base-sentiment-latest \
    --version=1.0 \
    --serialized-file ./pytorch_model.bin \
    --handler ./Transformer_handler_generalized.py \
    --extra-files './config.json,./setup_config.json,./index_to_name.json'

FROM pytorch/torchserve:latest-cpu

COPY --from=modelbuild --chown=model-server /home/model-server/twitter-roberta-base-sentiment-latest.mar ./model-store

COPY --chown=model-server requirements.txt ./

RUN pip install -r requirements.txt

CMD "torchserve --start --model-store ./model-store --models twitter-roberta-base-sentiment-latest=twitter-roberta-base-sentiment-latest.mar --ncs --foreground"