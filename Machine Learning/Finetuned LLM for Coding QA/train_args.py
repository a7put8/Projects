from dataclasses import dataclass, field ## Import necessary libraries to store data and represent certain datatypes
import os
from typing import Optional ## Optional allows for the argument to be of the specified data type of of None type

@dataclass
class ScriptArguments:

    hf_token: str = field(default="",metadata={"help": "Hugging face access token for user profile"}) ## Add access token to access HuggingFace environment


    model_name: Optional[str] = field(
        default="meta-llama/Llama-2-7b-hf", metadata={"help": "Name of the LLM being fine-tuned"} ## HuggingFace Model being used for model training/ fine tuning
    )

    seed: Optional[int] = field(
        default=4761, metadata = {'help':'Set seed to ensure reproducibility of the model outputs'} ## Set seed for reproducibility
    )

    data_path: Optional[str] = field(
        default="jbrophy123/stackoverflow_dataset", metadata={"help": "path for the dataset hosted on HuggingFace"} ## HuggingFace Data path
    )

    output_dir: Optional[str] = field(
        default="output", metadata={"help": "Output directory for the model to store output"} ## Directory to save model output
    )
    
    per_device_train_batch_size: Optional[int] = field(
        default = 2, metadata = {"help":"Specifies the number of samples to process in a single batch per device when training the model"} ## How much data to process per training batch
    )

    gradient_accumulation_steps: Optional[int] = field(
        default = 4, metadata = {"help":"Number of gradients to accumulate before taking the next step in the optimizer"} ## Accumulate gradients over several batches, and then performs an update
    )

    optim: Optional[str] = field(
        default = "paged_adamw_32bit", metadata = {"help":"Optimizer to use that has weight decay fixed"} ## Paged Adam algorithm being used to implement quantized model (QLoRA) for efficient training
    )

    save_steps: Optional[int] = field(
        default = 500, metadata = {"help":"Number of updates steps before two checkpoint saves"} ## Number of steps before saving
    )

    logging_steps: Optional[int] = field(
        default = 5, metadata = {"help":"Number of update steps between two logs"} ## Number of steps before creating logs
    )

    learning_rate: Optional[float] = field(
        default = 2e-4, metadata = {"help":"The initial learning rate for the algorithm being used"} ## initial eta value for the gradient descent when the model starts learning
    )

    max_grad_norm: Optional[float] = field (
        default = 0.3, metadata = {"help":"Threshold value for gradient norm to avoid gradient explosion"} ## To avoid excessively large gradients that hinder convergence and make model unstable
    )

    num_train_epochs: Optional[int] = field (
        default = 2, metadata = {"help":"Number of times the entire training set is passed through the model"} ## Number of times model is passed through model for training, low number could lead to under fitting high number to over fitting
    ) ## smaller model which is a very good general model being used hence low number of epochs to avoid potential overfitting

    warmup_ratio: Optional[float] = field (
        default = 0.03, metadata = {"help":"Ratio of total training steps used for a linear warmup from 0 to learning_rate"} ## Fraction of total training steps for which warmup phase should take place
    )

    lr_scheduler_type: Optional[str] = field(
        default="cosine", metadata = {"help":"The scheduler type to use. Adjusts the learning rate over the course of training based on predefined strategy"} ## Cosine decay to reduce learning rate gradually
    ) 

    lora_dir: Optional[str] = field(
        default = "a7pute/llm_stackOverflowQA", metadata = {"help":"Directory to save the model"}) ## Save the model and outputs to hugging face account

    max_steps: Optional[int] = field(
        default=-1, metadata={"help": "Overrides num_train_epochs. If set to a positive number, the total number of training steps to perform. Passed into TrainingArguments(max_steps)"}
        ) ## Same as num_train_epochs and can be used in place of it for the training to reiterate through the dataset (if all data is exhausted) until max_steps is reached

    text_field: Optional[str] = field(
        default='chat_sample', metadata={"help": "The name of the text field of the dataset. Training data column name of the dataset being used. Will be passed to SFTTrainer(dataset_text_field)"}
        ) ## The name of the text field of the dataset, in case this is passed by a user, the trainer will automatically create a ConstantLengthDataset based on the dataset_text_field argument


