CREATE TABLE IF NOT EXISTS incident_logs (
    id SERIAL PRIMARY KEY,
    server_name VARCHAR(100),
    action_taken VARCHAR(50),
    reasoning TEXT,
    confidence INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
