# Tech Assessment Agent

Author: [Carlos J. Ramirez](https://www.carlosjramirez.com)

Technical Assessment Agent for the oTTomator Live Agent Studio.

It consists of a [n8n](https://n8n.io/) workflow with a Technical Assessment Agent that completing a Review Report based on provided whiteboard and behavioral type interview notes, suitable for software engineers and developers.

The "Agent" node manages conversation history itself and is compatible with the [oTTomator Live Agent Studio](https://studio.ottomator.ai).

## Core Components

1. **Webhook Endpoint**
   - Accepts POST requests with authentication
   - Processes incoming queries with user and session information
   - Provides secure communication via header authentication

2. **Input Processing**
   - Extracts key fields from incoming requests:
     - query: The user's question or command
     - user_id: Unique identifier for the user
     - request_id: Request tracking ID
     - session_id: Current session identifier

3. **Database Integration**
   - Uses Supabase for message storage
   - Records both user messages and AI responses
   - Maintains conversation history with metadata

4. **Chat Model**
   - Uses any [OpenRouter](https://openrouter.ai/models) model

5. **Response Handling**
   - Structured response format for consistency
   - Includes success/failure status
   - Returns formatted responses via webhook

## Usage

### Native n8n chat interface

1. In the `n8n` UI, create a Workflow. Name it `Technical Assessment Agent (n8n)`.

2. Import the Workflow JSON file: [Technical_Assessment_Agent_n8n.json](n8n/workflow/Technical_Assessment_Agent_n8n.json).

3. Set the required credentials and other configurations in the Workflow (more information in the [Auth Credentials and other configurations](#auth-credentials-and-other-configurations) section).

4. Start the n8n server.

```bash
make run
```

5. Make sure the workflow is running.

    - Go to `n8n UI > Home > Technical Assessment Agent (n8n)`.

6. Get the Webhook Endpoint.

    - Go to `n8n UI > Home > Technical Assessment Agent (n8n) > When chat message received > Chat URL`.
    - Copy the URL.

7. Chat with the agent.

    - Paste the Chat URL in a new tab.
    - Chat with the agent following the instructions in the section [Chat with the Technical Assessment Agent](#chat-with-the-technical-assessment-agent).

### oTTomator Live Agent Studio

1. In the `n8n` UI, create a Workflow. Name it `Technical Assessment Agent (oTTomator)`.

2. Import the Workflow JSON file: [Technical_Assessment_Agent_ottomator.json](n8n/workflow/Technical_Assessment_Agent_ottomator.json).

3. Set the required credentials and other configurations in the Workflow (more information in the [Auth Credentials and other configurations](#auth-credentials-and-other-configurations) section).

4. Sign in to the [oTTomator Studio](https://studio.ottomator.ai).

5. Go to [Agent 0](https://studio.ottomator.ai/agent/0).

6. Click on the `Gear` icon.

7. Set the required data in the `Agent Zero Configuration` section:

* **Supabase Project URL**: find it on `Supabase dashboard > Project > Project API`
* **Supabase Anon Key**: find it on `Supabase dashboard > Project > Project API`
* **Agent Endpoint**: find it on `n8n UI > Home > Technical Assessment Agent > Webhook Endpoint > Production URL`
* **Bearer Token**: find it on `n8n UI > Home > Technical Assessment Agent > Webhook Endpoint > Authorization > Bearer Token`

8. Click on the **Save** button.

9. Chat with Agent 0:

    - Click on **New Conversation** in the **Agent 0** UI.
    - Chat with the agent following the instructions in the section [Chat with the Technical Assessment Agent](#chat-with-the-technical-assessment-agent).

## Auth Credentials and other configurations

1. To Configure the Webhook Endpoint **Authorization Bearer token**, the credential data should be:<br/>
    * `Name` will be `Authorization`.
    * `Value` will be `Bearer [token]`.<br/><br/>
    For more information, check [this](https://docs.n8n.io/integrations/builtin/credentials/httprequest) documentation.<br/>
    You can select any value of your choice for the `[token]`.

2. OpenRouter as Chat Model

    * **Add a Credential** using the endpoint: `https://openrouter.ai/api/v1` and your API Key.

    * **Specify a model** check for the model name in the [Models](https://openrouter.ai/models) page, click on the model id, then double click on the `OpenAI Chat Model` node, click on `expression` and paste the model id.

3. Chat Memory with Supabase 

    * **Add a Credential**

    1. use the `Transaction Pooler` instructions shown in the Supabase connection documentation for the database to be used with this workflow. 
    
    2. Use the password specified when you created the Supabase account.

    * **Configure the Key**: it must be the expression
`{{ $json.session_id }}`

4. Storing Messages in the Supabase Database

    * Use this SQL to create the messages table:

```sql
-- Enable the pgcrypto extension for UUID generation
-- Note: If you're using Supabase, the pgcrypto extension
-- is already enabled by default.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
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

Find more information about the database integration on the [oTtomator Studio documentation](https://studio.ottomator.ai/guide)

## Chat with the Technical Assessment Agent

If you need a template for the interview notes, ask: **give me the notes template**

If you need to know the interview types, ask: **give me the interview goals**

If you want to know the default seniority levels, ask: **give me the seniority levels**

When you are ready with all the required information, provide the notes from the technical review.

If there are missing required data, the agent wil ask for it.

Once all the required data is provided, the agent will generate the report.

## Local Development environment

To run the workflow locally, follow these steps:

1. Go to the `n8n` directory: `cd n8n`

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