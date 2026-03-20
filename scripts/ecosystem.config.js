module.exports = {
  apps: [
    {
      name: 'midterm-app',
      script: './main.js',
      cwd: '/var/www/midterm-app/src/sample-midterm-project/sample-midterm-node.js-project',
      instances: '1',
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        MONGO_URI: 'mongodb://localhost:27017/products_db'
      },
      merge_logs: true,
      autorestart: true,
      max_memory_restart: '500M',
      watch: false,
      ignore_watch: ['node_modules', 'public/uploads', 'logs'],
      max_restarts: 10,
      min_uptime: '10s',
      listen_timeout: 10000,
      kill_timeout: 5000,
      restart_delay: 3000,
      shutdown_with_message: true
    }
  ]
};
