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
