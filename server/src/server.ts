import type { ErrorRequestHandler } from "express";
import express from "express";
import { env } from "node:process";
import {
  INTERNAL_SERVER_ERROR,
  NO_CONTENT,
} from "./http-status-code.js";
import cors from "cors";

const CLIENT_ORIGIN = "https://<<REPO_NAME>>-jgerard.vercel.app";
const PORT: number = parseInt(env.PORT ?? '3000', 10);
const app = express();

// Enable CORS for the Angular client
app.use(
  cors({
    allowedHeaders: "Content-Type",
    maxAge: 86400,
    methods: "POST",
    optionsSuccessStatus: NO_CONTENT,
    origin: env.HEROKU_ENV === "production" ? CLIENT_ORIGIN : "*",
    preflightContinue: false,
  }),
);

// Parse JSON requests
app.use(express.json());

app.get("/api/test", (req, res) => {
  res.send("Server is up and running!");
});

const defaultErrorHandler: ErrorRequestHandler = (err, req, res, next) => {
  if (res.headersSent) return next(err);

  console.error(err);
  res.status(INTERNAL_SERVER_ERROR).json({
    message:
      "Sorry, an unexpected error occurred on our end.\n" +
      "Please try again later.\n\n" +
      "If the problem persists, send us an email at support@example.com.",
  });
};

app.use(defaultErrorHandler);

if (env.NODE_ENV === "production") {
  // Omitted host defaults to 0.0.0.0 or [::] if IPv6 is supported
  app.listen(PORT, () => {
    console.log("Server listening on port", PORT);
  });
} else {
  const HOST = "localhost";

  app.listen(PORT, HOST, () => {
    console.log(`Server listening at http://${HOST}:${PORT}`);
  });
}
