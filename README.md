# Tech Assessment Agent

Author: [Carlos J. Ramirez](https://www.carlosjramirez.com)

Tech Assessment Agent based on AI that completing a Review Report from provided interview notes (whiteboard and behavioral interviews), suitable for software engineers and developers.

It consists of [n8n](https://n8n.io/) workflows that runs the Technical Assessment Agent, manages conversation history and provide a Chat interface for:

* [n8n](https://n8n.io/)
* [oTTomator Live Agent Studio](https://studio.ottomator.ai)

## Core Components

1. **Webhook Endpoint**
   - Accepts POST requests with authentication
   - Processes incoming queries with user and session information
   - Provides secure communication via header authentication

2. **Input Processing**
   - Extracts key fields from incoming requests:

     For n8n:
     - sessionId: Current session identifier
     - action: The action to be performed. E.g. `sendMessage`
     - chatInput: The user's question or command

     For Ottomator:
     - query: The user's question or command
     - user_id: Unique identifier for the user
     - request_id: Request tracking ID
     - session_id: Current session identifier

3. **Database Integration**
   - Uses Supabase for message storage
   - Records both user messages and AI responses
   - Maintains conversation history with metadata

4. **Chat Model**
   - Uses any [OpenRouter](https://openrouter.ai/models) models by default, and can be modified to use any [OpenAI completions-compatible](https://platform.openai.com/docs/api-reference/introduction) LLM provider.

5. **Response Handling**
   - Structured response format for consistency
   - Includes success/failure status
   - Returns formatted responses via webhook

## Usage

### Start the n8n server

You can use a local server or cloud server:

- **Local server**: follow instructions in the [Local Development environment](#local-development-environment) section.

- **Cloud server**: go to [https://app.n8n.cloud/](https://app.n8n.cloud/), create a new account or use an existing one.

### Native n8n chat interface

1. In the `n8n` UI, create a Workflow. Name it `Technical Assessment Agent (n8n)`.

2. Import the Workflow JSON file: [Technical_Assessment_Agent_n8n.json](n8n/workflow/Technical_Assessment_Agent_n8n.json).

3. Set the required credentials and other configurations in the Workflow (more information in the [Auth Credentials and other configurations](#auth-credentials-and-other-configurations) section).

5. Make sure the workflow is running.

    - Go to `n8n UI > Home > Technical Assessment Agent (n8n)`.
    - Click on the `Inactive` button so it changes to `Active` (green).
    - Click on the `Got it` button.

6. Get the Chat Endpoint.

    - Double click on the `When chat message received` node.
    - Copy the URL in the `Chat URL` section.

7. Configure credential for the chat interface.

    Check the [Auth Credentials and other configurations](#auth-credentials-and-other-configurations) section.

8. Chat with the agent.

    - Paste the Chat URL in a new tab.
    - Provide the `Username` and `Password` configured in the previous step.
    - Chat with the agent following the instructions in the section [Chat with the Technical Assessment Agent](#chat-with-the-technical-assessment-agent).

### oTTomator Live Agent Studio

1. In the `n8n` UI, create a Workflow. Name it `Technical Assessment Agent (oTTomator)`.

2. Import the Workflow JSON file: [Technical_Assessment_Agent_ottomator.json](n8n/workflow/Technical_Assessment_Agent_ottomator.json).

3. Set the required credentials and other configurations in the Workflow (more information in the [Auth Credentials and other configurations](#auth-credentials-and-other-configurations) section).

4. Sign in to the [oTTomator Live Agent Studio](https://studio.ottomator.ai).

5. Go to [Agent 0](https://studio.ottomator.ai/agent/0).

6. Click on the `Gear` icon.

7. Set the required data in the `Agent Zero Configuration` section:

* **Supabase Project URL**: find it on `Supabase dashboard > Project > Project API`
* **Supabase Anon Key**: find it on `Supabase dashboard > Project > Project API`
* **Agent Endpoint**: find it on `n8n UI > Home > Technical Assessment Agent (oTTomator) > Webhook Endpoint > Production URL`
* **Bearer Token**: find it on `n8n UI > Home > Technical Assessment Agent (oTTomator) > Webhook Endpoint > Authorization > Bearer Token`

8. Click on the **Save** button.

9. Chat with Agent 0:

    - Click on **New Conversation** in the **Agent 0** UI.
    - Chat with the agent following the instructions in the section [Chat with the Technical Assessment Agent](#chat-with-the-technical-assessment-agent).

## Auth Credentials and other configurations

1. Configure **User and Password** to authenticate the chat interface.

    - Double click on the `When chat message received` node.
    - In the `Authentication` section, the `Basic Auth` option should be selected.
    - Click on the `Credential for Basic Auth` field, then select the `Create new credential` or select a existing credential (and click on the `pencil` icon to edit it).
    - Provide the credentials to be used when you want to run the chat interface in the `User` and `Password` fields.
    - Click on the `Save` button.<BR/><BR/>
    For more information, check [this](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.chattrigger/) documentation.

2. Configure the Webhook Endpoint **Authorization Bearer token**, the credential data should be:<br/>
    * `Name` will be `Authorization`.
    * `Value` will be `Bearer [token]`.<br/><br/>
    For more information, check [this](https://docs.n8n.io/integrations/builtin/credentials/httprequest) documentation.<br/>
    You can select any value of your choice for the `[token]`.

3. OpenRouter as Chat Model

    * **Add a Credential** using the endpoint: `https://openrouter.ai/api/v1` and your API Key.

    * **Specify a model** check for the model name in the [Models](https://openrouter.ai/models) page, click on the model id, then double click on the `OpenAI Chat Model` node, click on `expression` and paste the model id.

3. Chat Memory with Supabase 

    * **Add a Credential**

    1. use the `Transaction Pooler` instructions shown in the Supabase connection documentation for the database to be used with this workflow. 
    
    2. Use the password specified when you created the Supabase account.

    * **Configure the Key**: it must be the expression
`{{ $json.session_id }}`

4. Storing Messages in the Supabase Database

    * For n8n: it will create the table automatically.

    * For oTTomator Live Agent Studio: use this SQL to create the messages table:

```sql
-- Enable the pgcrypto extension for UUID generation
-- Note: If you're using Supabase, the pgcrypto extension
-- is already enabled by default.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Create the messages table
CREATE TABLE messages (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    session_id TEXT NOT NULL,
    message JSONB NOT NULL
);
CREATE INDEX idx_messages_session_id ON messages(session_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

    * Enable `realtime updates` for testing (with Agent 0) by running this SQL command:

```sql
alter publication supabase_realtime add table messages;
```

Find more information about the database integration on the [oTTomator Live Agent Studio documentation](https://studio.ottomator.ai/guide)

## System prompt

The system prompt is the prompt that is sent to the chat model to guide the conversation.

The system prompt for the Agent is located in the file [prompts/Tech-Assessment-Agent-System-Prompt-english.md](prompts/Tech-Assessment-Agent-System-Prompt-english.md). There are version of the prompt in different languages, check the folder [prompts](prompts).

In case you need to change the system prompt, edit the corresponding file, copy the content and paste it in the n8n UI:

1. Go to `n8n UI > Home > Technical Assessment Agent (n8n or oTTomator)`.
2. Double click on it.
3. Go to the `AI Agent` node.
4. Double click on it.
5. In the `System Prompt` field, paste the content copied.
6. Click on the `Back to canvas` hyperlink.
7. Click on the `Save` button.

Once the workflow is saved, you can make a backup in a JSON file:

1. Click on the `...` button.
2. Click on `Download`.
3. Save the file in a safe location.

## Chat with the Technical Assessment Agent

The Agent works with a chat interface where you can ask questions and get answers.

The idea is you provide the notes from the technical review and the agent will generate the report. Those notes should follow the template provided by the agent and have a series of suggested questions you can ask to the candidate or colleague.

When you are ready with all the required information, copy and paste the notes from the technical review to the chat interface.

If there are missing required data, the agent will ask for it.

Once all the required data is provided, the agent will generate the report.

### Get help

If you need guidance, type: **help**

### Notes template

If you need a template for the interview notes, ask: **give me the notes template**

### Interview goals

If you need to know the interview types, ask: **give me the interview goals**

### Seniority levels

If you want to know the default seniority levels, ask: **give me the seniority levels**

## Local Development environment

To run the workflow locally, follow these steps:

1. Go to the `n8n` directory in the root of the project: `cd n8n`

2. Create the `.env` file:

```bash
cp .env.example .env
vi .env
# set the variables according to your needs.
```

3. Start the n8n local server: `make run`

4. Open the `n8n` UI in your browser: `http://127.0.0.1:5678`

5. The first time it will ask for a new administrator user and password.

6. Follow the rest of the instructions in the [Usage](#usage) to set credentials, other configurations, and test the workflow with the Agent 0 UI.

To access the PG Admin UI, go to: `http://127.0.0.1:8765`

To restart the local server, run: `make restart`

To stop the local server, run: `make stop`

To shutdown the local server, run: `make down`

To check the local server logs, run: `make logs`

To update the local server containers, run: `make update`

## License

This project is open-sourced software licensed under the [MIT license](LICENSE).

## Credits

This project is developed and maintained by Carlos Ramirez. For more information or to contribute to the project, visit [Tech Assessment Agent Node on GitHub](https://github.com/tomkat-cr/tech-assessment-agent).

Happy Coding!