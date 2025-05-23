#!/bin/bash

echo "🔧 Setting up Node-RED with pre-configured flows..."

# Create Node-RED config directory
mkdir -p config/node-red

# Copy flows.json to config directory if it doesn't exist there
if [[ -f flows.json && ! -f config/node-red/flows.json ]]; then
    echo "📋 Copying flows.json to config/node-red/..."
    cp flows.json config/node-red/
elif [[ ! -f config/node-red/flows.json ]]; then
    echo "❌ Error: flows.json not found in current directory or config/node-red/"
    echo "Please ensure flows.json exists before running this script."
    exit 1
fi

# Create Node-RED settings.js if it doesn't exist
if [[ ! -f config/node-red/settings.js ]]; then
    echo "⚙️ Creating Node-RED settings.js..."
    cat > config/node-red/settings.js << 'EOF'
module.exports = {
    uiPort: process.env.PORT || 1880,
    httpAdminRoot: '/admin',
    httpNodeRoot: '/api',
    userDir: '/data',
    flowFile: 'flows.json',

    // Security
    credentialSecret: process.env.NODE_RED_CREDENTIAL_SECRET || "docpro-secret-key",

    // Admin authentication (optional)
    adminAuth: {
        type: "credentials",
        users: [{
            username: "admin",
            password: "$2a$08$zZWtXTja0fB1pzD4sHCMyOCMYz2Z6dNbM6tl8sJogENOMcxWV9DN.",
            permissions: "*"
        }]
    },

    // HTTP Node settings
    httpNodeCors: {
        origin: "*",
        methods: "GET,PUT,POST,DELETE"
    },

    // Function node settings
    functionGlobalContext: {
        moment: require('moment'),
        _: require('lodash')
    },

    // Logging
    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },

    // Editor settings
    editorTheme: {
        projects: {
            enabled: false
        },
        palette: {
            editable: true
        }
    }
}
EOF
fi

# Stop Node-RED if running
echo "🛑 Stopping Node-RED..."
docker-compose stop node-red

# Remove existing Node-RED data to force reload
echo "🗑️ Cleaning Node-RED data..."
sudo rm -rf data/node-red/flows.json
sudo rm -rf data/node-red/.flows.json.backup

# Start Node-RED with new configuration
echo "🚀 Starting Node-RED with pre-configured flows..."
docker-compose up -d node-red

# Wait for Node-RED to start
echo "⏳ Waiting for Node-RED to start..."
sleep 15

# Check if Node-RED is running
if curl -s http://localhost:${NODE_RED_PORT:-1880} > /dev/null; then
    echo "✅ Node-RED is running!"
    echo "📊 Dashboard: http://localhost:${NODE_RED_PORT:-1880}"
    echo "🔧 Admin UI: http://localhost:${NODE_RED_PORT:-1880}/admin"

    # Check if flows are loaded
    if curl -s http://localhost:${NODE_RED_PORT:-1880}/flows | grep -q "doc-processing-tab"; then
        echo "✅ Document processing flows loaded successfully!"
    else
        echo "⚠️ Flows may not be loaded yet. Check Node-RED logs:"
        echo "   docker-compose logs node-red"
    fi
else
    echo "❌ Node-RED is not responding. Check logs:"
    echo "   docker-compose logs node-red"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Open Node-RED: http://localhost:${NODE_RED_PORT:-1880}"
echo "2. Deploy flows if needed (click Deploy button)"
echo "3. Test by dropping a document in data/input/"
echo "4. Monitor processing in debug panel"