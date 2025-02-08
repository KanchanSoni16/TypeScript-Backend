import express, { Request, Response } from "express";
import pool from "./db";

const app = express();
app.use(express.json());

app.post("/log", async (req: Request, res: Response): Promise<void> => {
  try {
    const { json_data } = req.body;
    if (!json_data) {
      res.status(400).json({ error: "json_data is required" });
      return;
    }

    const result = await pool.query(
      "INSERT INTO log (json) VALUES ($1) RETURNING *",
      [json_data]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});

app.get("/logs", async (req: Request, res: Response): Promise<void> => {
  try {
    const result = await pool.query("SELECT * FROM log ORDER BY inserted_at DESC");
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).send("Server error");
  }
});

const PORT: number = Number(process.env.PORT) || 3000;
app.listen(PORT, "0.0.0.0", () => console.log(`Server running on port ${PORT}`));
