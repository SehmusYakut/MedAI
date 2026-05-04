# MedAI - API Key Setup Guide

This guide provides step-by-step instructions for obtaining API keys for all supported AI services in MedAI.

## Table of Contents
1. [OpenAI (ChatGPT)](#openai-chatgpt)
2. [Google Gemini](#google-gemini)
3. [Mistral AI](#mistral-ai)
4. [Anthropic (Claude)](#anthropic-claude)
5. [Groq](#groq)
6. [HuggingFace](#huggingface)
7. [OpenRouter](#openrouter)

---

## OpenAI (ChatGPT)

### Get ChatGPT API Key

1. Visit [OpenAI Platform](https://platform.openai.com)
2. Sign up or log in to your account
3. Click on **API keys** in the left sidebar
4. Click **Create new secret key**
5. Copy the key (it starts with `sk-`)
6. **Important**: Save this key securely - you won't see it again

### Pricing
- Pay-as-you-go model
- gpt-3.5-turbo: ~$0.0015 per 1K tokens
- Free trial credits: $5 (valid for 3 months)

### Supported Models
- `gpt-3.5-turbo` (current default in MedAI)
- `gpt-4` (more expensive, better quality)

**Where to enter in MedAI**: Settings → API Key Management → ChatGPT API Key

---

## Google Gemini

### Get Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/apikey)
2. Click **Create API key**
3. Select or create a Google Cloud project
4. The API key will be generated automatically
5. Copy the key (starts with `AIzaSy...`)

### Pricing
- **FREE Tier**: 60 requests per minute (perfect for testing)
- **Paid Tier**: Higher rate limits available

### Supported Models
- `gemini-2.5-pro` (current default in MedAI)
- `gemini-1.5-pro`
- `gemini-1.5-flash` (faster, cheaper)

### Tips
- Gemini is completely free for testing with rate limits
- Excellent for medical text analysis
- Very fast response times

**Where to enter in MedAI**: Settings → API Key Management → Gemini API Key

---

## Mistral AI

### Get Mistral API Key

1. Visit [Mistral Console](https://console.mistral.ai)
2. Sign up with email or GitHub
3. Go to **API keys** section
4. Click **Generate new key**
5. Copy your API key
6. Set a usage limit for security

### Pricing
- Free trial: €5 credit
- Pay-as-you-go pricing
- `mistral-tiny`: Very affordable (~€0.14 per 1M tokens)
- `mistral-small`: Better quality, higher cost

### Supported Models
- `mistral-tiny` (current default in MedAI)
- `mistral-small`
- `mistral-medium`

### Advantages
- Very affordable pricing
- Based in Europe (good for GDPR compliance)
- Fast inference

**Where to enter in MedAI**: Settings → API Key Management → Mistral API Key

---

## Anthropic (Claude)

### Get Claude API Key

1. Visit [Anthropic Console](https://console.anthropic.com)
2. Sign up or log in
3. Go to **API Keys** section
4. Click **Create Key**
5. Name your key (e.g., "MedAI-mobile")
6. Copy the key (starts with `sk-ant-`)

### Pricing
- Pay-as-you-go model
- Claude 3 Opus: $15 per 1M input tokens, $75 per 1M output tokens
- Claude 3 Sonnet: $3 per 1M input tokens, $15 per 1M output tokens
- Claude 3 Haiku: $0.25 per 1M input tokens, $1.25 per 1M output tokens
- Claude 2: Cheaper but older model

### Supported Models
- `claude-3-sonnet-20240229` (recommended for MedAI - good balance)
- `claude-3-opus-20240229` (most capable)
- `claude-3-haiku-20240307` (fastest, cheapest)

### Advantages
- Excellent for medical document analysis
- Strong reasoning capabilities
- Good context window

**Where to enter in MedAI**: Settings → API Key Management → Claude API Key

---

## Groq

### Get Groq API Key

1. Visit [Groq Console](https://console.groq.com)
2. Sign up or log in with GitHub/Google
3. Go to **API Keys** section
4. Click **Create API Key**
5. Copy your API key
6. Set appropriate limits

### Pricing
- **FREE Tier**: 
  - 14,000 requests per minute
  - Very fast inference (excellent for testing)
  - No rate limiting for moderate use
- Paid tiers available for production

### Supported Models
- `mixtral-8x7b-32768` (fast, good quality)
- `llama-2-70b-chat-4096` (good for conversations)
- Various other open-source models

### Advantages
- Extremely fast response times
- Free tier is generous
- Great for initial development
- Perfect for learning and prototyping

**Where to enter in MedAI**: Settings → API Key Management → Groq API Key

---

## HuggingFace

### Get HuggingFace API Key

1. Visit [HuggingFace](https://huggingface.co)
2. Sign up or log in
3. Click your profile → **Settings** → **Access Tokens**
4. Click **New token**
5. Give it a name (e.g., "MedAI")
6. Select **Read** permission
7. Copy the token (starts with `hf_`)

### Pricing
- Free tier available
- Paid inference API available
- Open-source models available
- Requires your own compute for some models

### Supported Models
- Access to 1M+ open-source models
- Popular medical models available
- BioGPT for biomedical text
- SciBERT for scientific documents

### Advantages
- Access to unlimited open-source models
- Community-driven models
- Good for medical/scientific NLP
- Can use locally or via API

**Where to enter in MedAI**: Settings → API Key Management → HuggingFace API Key

---

## OpenRouter

### Get OpenRouter API Key

1. Visit [OpenRouter](https://openrouter.ai)
2. Sign up or log in
3. Go to **Keys** section
4. Click **Create Key**
5. Copy your API key
6. Set usage limits

### Pricing
- No subscription required
- Pay-per-use pricing
- Aggregates prices from multiple providers
- Often cheaper than direct API calls
- Free trial credits available

### Supported Models
- 100+ models available
- ChatGPT models
- Claude models
- Open-source models
- Price comparison available for each query

### Advantages
- Use multiple models with one API key
- Automatic fallback if model is down
- Excellent for comparing different AI services
- Transparent pricing across all models

**Where to enter in MedAI**: Settings → API Key Management → OpenRouter API Key

---

## Quick Comparison Table

| Service | Free Tier | Speed | Quality | Cost |
|---------|-----------|-------|---------|------|
| **ChatGPT** | $5 trial | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | $$$ |
| **Gemini** | ✅ Yes | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Free |
| **Mistral** | €5 trial | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | $$ |
| **Claude** | ❌ No | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | $$$$ |
| **Groq** | ✅ Yes | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Free |
| **HuggingFace** | ✅ Yes | ⭐⭐⭐ | ⭐⭐⭐ | $ |
| **OpenRouter** | ✅ Yes | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | $$ |

---

## Security Best Practices

### ⚠️ Important Security Guidelines

1. **Never share your API keys**
   - Do not commit them to version control
   - Do not share in chat or email
   - Treat them like passwords

2. **Use environment variables** (when available)
   - Avoid hardcoding keys in code
   - MedAI stores keys securely using SharedPreferences

3. **Set usage limits**
   - Configure rate limits in your API provider's dashboard
   - Set maximum monthly spending limits
   - Monitor your usage regularly

4. **Rotate keys regularly**
   - Delete old keys you no longer use
   - Regenerate keys if compromised
   - Use separate keys for development and production

5. **Monitor your account**
   - Check your API usage logs monthly
   - Set up billing alerts
   - Review recent activity

---

## Recommended Setup for Getting Started

### Option 1: FREE Services (No Cost)
Best for learning and testing:
1. **Gemini API** - Free with rate limits (60 req/min)
2. **Groq** - Free with generous rate limits (14,000 req/min)

### Option 2: Budget-Friendly
Best for low-cost production:
1. **Mistral** - Very affordable (€5 free trial)
2. **Gemini** - Free tier with upgradeable options
3. **Groq** - Free tier for high speed

### Option 3: Feature-Rich
Best for maximum capabilities:
1. **Claude** - Excellent for medical analysis
2. **ChatGPT** - Most reliable, widely used
3. **Gemini** - Fast and free for testing

---

## Troubleshooting

### Issue: "Invalid API Key"
**Solution**: 
- Check that you copied the entire key
- Verify the key matches the service
- Ensure the key hasn't expired
- Try regenerating the key from the provider's dashboard

### Issue: "Rate limit exceeded"
**Solution**:
- Use a service with higher free tier (Groq)
- Wait before sending more requests
- Upgrade to paid plan
- Use OpenRouter to distribute load

### Issue: "Service unavailable"
**Solution**:
- Check internet connection
- Verify the API endpoint is working
- Try a different AI service
- Check service status page

### Issue: "Poor response quality"
**Solution**:
- Try a better model (Claude 3 Opus instead of Haiku)
- Provide more context in your prompt
- Try a different service
- Use more specific medical terminology

---

## API Key Status in MedAI

You can check which API keys are currently configured in the app:
- Open **Settings** → **API Key Management**
- Keys marked with ✅ are active
- Keys marked with ❌ are not configured

## Support

For additional help:
- Check individual service documentation
- Review the MedAI README.md
- Open an issue on the GitHub repository
- Contact the development team

---

**Last Updated**: May 2026
**MedAI Version**: 1.0+
