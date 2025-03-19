# Contexts and Sessions in Fabric

This guide explains how contexts and sessions work in Fabric and how to use them effectively via the command line interface.

## Concepts

### Contexts

**Contexts** are text containers that store system-level information which is provided to LLMs during chat interactions. They serve as persistent background information or instructions that can be reused across different conversations.

- Each context has a unique name and content
- Contexts are stored as text files in `~/.config/fabric/contexts/`
- They provide consistent system instructions across multiple conversations

### Sessions

**Sessions** are chat conversations that maintain state between interactions, allowing for multi-turn conversations with LLMs.

- Each session has a unique name and an ordered list of messages
- Sessions contain both user and assistant messages representing the conversation history
- Sessions are stored as JSON files in `~/.config/fabric/sessions/`
- They enable the AI to remember previous exchanges in a conversation

### How They Work Together

The `Chatter.BuildSession` method combines:
- Context content (if specified)
- Session history (if specified)
- Pattern content (if specified)
- User's new message

This combined information creates a complete prompt for the AI, where:
1. Context and pattern content form the system message
2. Previous messages in the session provide conversation history
3. The user's new message is added to the session
4. The entire package is sent to the AI vendor

## Basic Commands

### Context Commands

**List all contexts:**
```
fabric --listcontexts
# or short form
fabric -x
```

**Print a specific context:**
```
fabric --printcontext <context-name>
```

**Delete a context:**
```
fabric --wipecontext <context-name>
# or short form
fabric -w <context-name>
```

**Use a context in a conversation:**
```
fabric --context <context-name> "Your message"
# or short form
fabric -C <context-name> "Your message"
```

### Session Commands

**List all sessions:**
```
fabric --listsessions
# or short form
fabric -X
```

**Print a specific session:**
```
fabric --printsession <session-name>
```

**Delete a session:**
```
fabric --wipesession <session-name>
# or short form
fabric -W <session-name>
```

**Use a session in a conversation:**
```
fabric --session <session-name> "Your message"
```

## Creating and Using Contexts

### Creating a Context

1. **Direct creation with message:**
   ```
   fabric -C my_new_context "This is the content that will be saved as context"
   ```

2. **Create from file:**
   Create a file in `~/.config/fabric/contexts/` with your desired content.

### Using a Context

```
fabric -C my_project_context "What do you know about my project?"
```

With a pattern:
```
fabric -C my_project_context -p analyze_code "What improvements can be made?"
```

## Creating and Using Sessions

### Starting a New Session

```
fabric --session my_chat_session "Hello, this is our first message"
```

### Continuing a Session

```
fabric --session my_chat_session "This is my follow-up question"
```

### Using Context with Session

```
fabric -C my_project_context --session project_discussion "What are the key components?"
```

## Advanced Usage

### Combining Multiple Features

Use context, session, and pattern together:
```
fabric -C programming_context --session code_review -p analyze_code "How can I optimize this function?"
```

### Exporting Sessions

Export a session to a file:
```
fabric --printsession my_session > session_transcript.md
```

### Using with Pipes

Process clipboard content:
```
pbpaste | fabric -C project_specs -p extract_requirements
```

Process file content:
```
cat code.js | fabric -C javascript_context -p analyze_code
```

Process command output:
```
ls -la | fabric -C file_system "Explain these file permissions"
```

Chain commands:
```
cat log.txt | grep ERROR | fabric -C log_analysis "Summarize these errors"
```

### YAML Configuration

Create a configuration file:
```yaml
# ~/.config/fabric/config.yaml
context: my_default_context
session: my_default_session
model: gpt-4
temperature: 0.7
```

Use with config:
```
fabric --config ~/.config/fabric/config.yaml "Your message"
```

### Session Management Workflow

1. **Create session for a project:**
   ```
   fabric --session project_x "Let's discuss project requirements"
   ```

2. **Continue discussion over multiple days:**
   ```
   fabric --session project_x "What were the key points we discussed yesterday?"
   ```

3. **Export the completed discussion:**
   ```
   fabric --printsession project_x > project_x_discussion.md
   ```

4. **Clean up when finished:**
   ```
   fabric -W project_x
   ```

## Tips and Best Practices

1. **Use descriptive names** for contexts and sessions to easily identify them later
2. **Keep contexts focused** on specific topics or projects for better results
3. **Create separate sessions** for different conversation threads
4. **Regularly export valuable sessions** to preserve important conversations
5. **Clean up old contexts and sessions** to manage storage space
6. **Combine contexts with patterns** for more specialized interactions