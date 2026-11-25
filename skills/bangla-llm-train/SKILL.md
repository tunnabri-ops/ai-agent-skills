---
name: bangla-llm-train
description: Use when training a small Bangla language model from scratch in PyTorch, including building a Bangla BPE tokenizer, pretraining a transformer, running supervised fine-tuning or LoRA, evaluating loss and perplexity, and producing a tiny CPU-runnable demo model.
---

# Bangla LLM Train

Train a small Bangla LLM from scratch in PyTorch. This skill covers the
full pipeline: data, tokenizer, pretraining, SFT, LoRA, evaluation, and a
tiny CPU demo. The reference implementation is
`tunnabri-ops/llm-bd` on GitHub — a from-scratch 64M-parameter Bangla model
with a Bangla BPE tokenizer, pretrain/SFT/LoRA trainers, a CLI chat, a
Streamlit WebUI, and an OpenAI-compatible API.

## When to Use This Skill

- The user wants to train, fine-tune, or evaluate a small Bangla LLM.
- The user asks for a tokenizer, pretraining run, SFT dataset, or LoRA adapter.
- The user wants a CPU demo of a Bangla model they can run without a GPU.

## Prerequisites

- Python 3.10+, PyTorch 2.x, `tokenizers`, `datasets`, `transformers` (LoRA only).
- A GPU is recommended for the full 64M model; the tiny demo runs on CPU.
- Bangla text data: plain `.txt` or `.jsonl` files, UTF-8, one document per line
  for pretraining, one `{"instruction", "input", "output"}` object per line for SFT.
- At least 1,000 pretraining documents and 300 SFT examples for a meaningful demo.

## Workflow

### 1. Prepare the data

1. Collect Bangla text: news, Wikipedia, books, conversations, QA pairs.
2. Normalise Unicode (NFC), strip HTML, collapse repeated whitespace.
3. Deduplicate exactly: hash each document and drop repeats.
4. Hold out a validation split (5%) before any training and never train on it.
5. Check the split: no validation document may appear in the training set.

```bash
python scripts/prepare_data.py --input data/raw --output data/clean --val-ratio 0.05
```

### 2. Train the BPE tokenizer

1. Train a byte-level BPE tokenizer on the cleaned Bangla corpus.
2. Use a vocabulary of 8,192 for a tiny model and 16,384 for the 64M model.
3. Add special tokens: `<pad>`, `<bos>`, `<eos>`, `<unk>`.
4. Save the tokenizer to `tokenizer/` and test round-trip encoding on Bangla text.

```bash
python scripts/train_tokenizer.py --data data/clean/train.txt --vocab 8192 --out tokenizer/
python scripts/test_tokenizer.py --tokenizer tokenizer/ --text "আমি বাংলায় কথা বলি"
```

### 3. Pretrain the model

1. Use a decoder-only transformer: 12 layers, 512 hidden size, 8 heads for 64M.
2. For the tiny CPU demo use 4 layers, 256 hidden size, 4 heads (about 5M params).
3. Train with AdamW, learning rate 3e-4, cosine decay, warmup 5% of steps.
4. Use batch size 32 and sequence length 256 for the tiny model, 512 for 64M.
5. Log training loss every 10 steps and validation loss every 200 steps.
6. Save a checkpoint every 500 steps and keep the best-validation checkpoint.

```bash
python scripts/pretrain.py --config configs/tiny.yaml --data data/clean --out runs/tiny
python scripts/pretrain.py --config configs/64m.yaml --data data/clean --out runs/64m
```

### 4. Supervised fine-tuning (SFT)

1. Format each example as instruction + input + output, ending with `<eos>`.
2. Mask the loss so it is computed only on the output tokens, never the prompt.
3. Train 2–3 epochs at learning rate 2e-5 with a cosine schedule.
4. Stop early if validation loss rises for two consecutive evaluations.
5. Save the fine-tuned weights separately; never overwrite the base checkpoint.

```bash
python scripts/sft.py --base runs/64m/best.pt --data data/sft.jsonl --out runs/sft
```

### 5. LoRA fine-tuning

1. Freeze the base model weights completely — only adapter weights may change.
2. Attach LoRA adapters to the query and value projections (`q_proj`, `v_proj`).
3. Use rank 8, alpha 16, dropout 0.05 for a first run.
4. Train with learning rate 1e-4; verify the trainable parameter count is under 1%.
5. Save only the adapter weights (`adapter_model.bin`), never a full copy.

```bash
python scripts/lora.py --base runs/64m/best.pt --data data/sft.jsonl --rank 8 --out runs/lora
```

### 6. Evaluate

1. Report training loss, validation loss, and held-out perplexity together.
2. Perplexity is `exp(validation_loss)` — lower is better, and it is only
   comparable on the same tokenizer and validation set.
3. Run a fixed generation test: 20 Bangla prompts, greedy decoding, max 64 tokens.
4. Record the results in `results/eval.md` with the exact checkpoint path and config.
5. Never report a perplexity measured on training data as a model-quality result.

```bash
python scripts/eval.py --checkpoint runs/sft/best.pt --data data/clean/val.txt
python scripts/generate.py --checkpoint runs/sft/best.pt --prompt "বাংলাদেশের রাজধানী"
```

### 7. Ship the tiny CPU demo

1. Train or load the tiny model (about 5M parameters, roughly 20 MB on disk).
2. Provide a CLI chat: `python chat.py --checkpoint runs/tiny/best.pt`.
3. Provide a one-command WebUI: `streamlit run app.py`.
4. Document the exact commands, expected first output, and hardware requirements.

## Checklist Before Reporting Done

- [ ] Data deduplicated and validation split held out with zero overlap.
- [ ] Tokenizer round-trips Bangla text without producing `<unk>` on common words.
- [ ] Pretraining loss decreased and validation loss was logged, not just training loss.
- [ ] SFT loss masked to output tokens only.
- [ ] LoRA run verified adapter-only (trainable parameters under 1%).
- [ ] Held-out perplexity reported with checkpoint path and config name.
- [ ] Tiny CPU demo runs end to end and produces Bangla text.

## Pitfalls

- Training on the validation set and reporting its perplexity as quality.
- Forgetting to mask prompt tokens in SFT, which teaches the model to repeat prompts.
- A LoRA run that silently unfreezes the base model — always print trainable counts.
- Mixing tokenizers between training and generation; always load the saved one.
- Reporting loss without saying which split and checkpoint it came from.
- Using English-only evaluation prompts for a Bangla model.
