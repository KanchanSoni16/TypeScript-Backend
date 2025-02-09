import { Pool } from "pg";
import dotenv from "dotenv";

dotenv.config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: Number(process.env.DB_PORT),
  ssl: { rejectUnauthorized: false } 
});

const createLogTable = async () => {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS log (
      id SERIAL PRIMARY KEY,
      inserted_at TIMESTAMPTZ DEFAULT now() NOT NULL,
      json JSON NOT NULL
    );
  `;

  try {
    await pool.query(createTableQuery);
    console.log("'log' table is ready.");
  } catch (error) {
    console.error("Error creating 'log' table:", error);
  }
};

// Execute the table creation function on startup
createLogTable();

export default pool;
