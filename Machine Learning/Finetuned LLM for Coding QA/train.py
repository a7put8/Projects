import os

import transformers ## Import critical library to use APIs to access NLP models hosted on HugginFace
from transformers import (
    AutoModelForCausalLM, ## Allows to load pretrained transformer model that is designed for causal language modelling taks
    AutoTokenizer, ## Used to tokenize the data for the specific pretrained model
    set_seed, ## To ensure reproducability
    BitsAndBytesConfig, ## For quantization (QLoRA maybe?) to reduce memory and computational costs by representing weights and activations with lower-precision data types like 8-bit integers (int8)
    Trainer, ## To use API for feature-complete training in PyTorch, and distributed training on GPUs
    TrainingArguments, ## To provide training arguments to pretrained models. Used to encapsulate variety of training relevant for traing and evaluation of model
    HfArgumentParser ## To generate the required arguments for use in command line to prepare to pass to model as parameters
)
from datasets import load_dataset ## Used for loading/ Accessing HuggingFace data. one-liners to download and pre-process any of the major public datasets provided on the HuggingFace Datasets Hub
import torch ## PyTorch for various operations. Specifically to typecast data in this context

import bitsandbytes as bnb ## Lightweight Python wrapper around CUDA custom functions
from huggingface_hub import login, HfFolder ## To loginto and access HuggingFace

from trl import SFTTrainer ## The library used for supervised finetuning of the chosen pretrained model

from utils import print_trainable_parameters, find_all_linear_names ## Import print_trainable_parameters, find_all_linear_names from utils.py

from train_args import ScriptArguments ## Import all the required arguments from train_args.py (train_args module)

from peft import LoraConfig, get_peft_model, PeftConfig, PeftModel, prepare_model_for_kbit_training ## Parameter Efficient Fine-Tuning library for LoRA. Decomposes pretrained model weights matrix into two smaller low-rank matrices in the attention layers

## LoraConfig: configuration class to store the configuration of a LoraModel
## get_peft_model: Returns a Peft model object from a model and a config.
## prepare_model_for_kbit_training: wraps the entire protocol for preparing a model before running a training
## PeftConfig:  base configuration class to store the configuration of a PeftModel
## PeftModel: base model class for specifying the base Transformer model and configuration to apply a PEFT method to. The base PeftModel contains methods for loading and saving models from the Hub

parser = HfArgumentParser(ScriptArguments) ## pass parameters from train_args to generate the required arguments in commandline friendly mode
args = parser.parse_args_into_dataclasses()[0] ## Parse command-line args into instances of the specified dataclass types. Prepare args for model from train_args module

def training_function(args):
    
    login(token=args.hf_token) ## Login the machine (VM here) to access the Hub

    set_seed(args.seed) ## Set seed for reproducability

    data_path=args.data_path ## access the data

    dataset = load_dataset(data_path) ## load dataset

    bnb_config = BitsAndBytesConfig( ## Quantize the data for faster processing
        load_in_4bit=True,
        bnb_4bit_use_double_quant=True,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.bfloat16, 
    )

    model = AutoModelForCausalLM.from_pretrained( ## Get the required model for our purpose i.e large general [urpose language pre-trained and can handle Q&A
        args.model_name, ## Here Llama2 7B
        use_cache=False,
        device_map="auto",
        quantization_config=bnb_config,
        trust_remote_code=True
    ) 

    tokenizer = AutoTokenizer.from_pretrained(args.model_name) ## Used for converting text input into format understandable my specified model hosted on HugginFace
    tokenizer.pad_token=tokenizer.eos_token ## Treat padding and end of sequence tokens as same. Depends from model to model. Here, specific for our chosend model
    tokenizer.padding_side='right' ## Right padding as original Llama codebase uses a default right padding

    model=prepare_model_for_kbit_training(model) ## Wrap model in protocol for preparing model before running training

    modules=find_all_linear_names(model) ## Identify modules that need to be fine-tuned i.e converted into LoRA which can be fine-tuned for our task
    config = LoraConfig( ## Prepare model configuration class to store the configuration of model to be fine-tuned
        r=64,
        lora_alpha=16,
        lora_dropout=0.1,
        bias='none',
        task_type='CAUSAL_LM',
        target_modules=modules ## The names of the modules/ weights to apply the adapter to, which is obtained from find_all_linear_names().
    ) ## adapters can modify the output of the linear modules, i.e. they can refine the pre-trained outputs in a way that is beneficial to the downstream-task

    model=get_peft_model(model, config) ## Returns a PEFT model object from using model and config from above
    output_dir = args.output_dir ## Set output directory parameter
    training_arguments = TrainingArguments( ## Encapsulate the hyperparameter and settings for our model. Parameters are being passed from data specified in train_args.py 
        output_dir=output_dir,
        per_device_train_batch_size=args.per_device_train_batch_size,
        gradient_accumulation_steps=args.gradient_accumulation_steps,
        optim=args.optim,
        save_steps=args.save_steps,
        logging_steps=args.logging_steps,
        learning_rate=args.learning_rate,
        bf16=False,
        max_grad_norm=args.max_grad_norm,
        num_train_epochs=args.num_train_epochs,
        warmup_ratio=args.warmup_ratio,
        group_by_length=True,
        lr_scheduler_type=args.lr_scheduler_type,
        tf32=False,
        report_to="none",
        push_to_hub=False,
        max_steps = args.max_steps
    )

    trainer = SFTTrainer(  ## Supervised fine-tuning Trainer. Create an instance for fine tuning model my passing all the parameters prepared above. I.e train our pre-trained model on the specified dataset and finetune/adjust specific weights (the LoRA converted weights) identified above
        model=model,
        train_dataset=dataset['train'].select(range(2000)), ## Train only on 2K datapoints due to compute constraints
        dataset_text_field=args.text_field,
        max_seq_length=2048,
        tokenizer=tokenizer,
        args=training_arguments
    )

    for name, module in trainer.model.named_modules():
        if "norm" in name:
            module = module.to(torch.float32) ## Ensure normalization layers operate with a specific precision

    print('starting training')

    trainer.train() ## Train model

    print('LoRA training complete')
    lora_dir = args.lora_dir
    trainer.model.push_to_hub(lora_dir, safe_serialization=False) ## Save trained model to specified directory
    
    print("saved lora adapters")

    

if __name__=='__main__': 
    training_function(args) ## If the module is not being imported and being run as the main file, then call training_function with argument args

