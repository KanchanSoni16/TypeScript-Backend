"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const db_1 = __importDefault(require("./db"));
const app = (0, express_1.default)();
app.use(express_1.default.json());
app.post("/log", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { json_data } = req.body;
        if (!json_data) {
            res.status(400).json({ error: "json_data is required" });
            return;
        }
        const result = yield db_1.default.query("INSERT INTO log (json) VALUES ($1) RETURNING *", [json_data]);
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error(error);
        res.status(500).send("Server error");
    }
}));
app.get("/logs", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const result = yield db_1.default.query("SELECT * FROM log ORDER BY inserted_at DESC");
        res.json(result.rows);
    }
    catch (error) {
        console.error(error);
        res.status(500).send("Server error");
    }
}));
const PORT = Number(process.env.PORT) || 3000;
app.listen(PORT, "0.0.0.0", () => console.log(`Server running on port ${PORT}`));
