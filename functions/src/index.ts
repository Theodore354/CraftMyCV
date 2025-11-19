/* eslint-disable */
/**
 * Firebase Functions v2 - OpenAI integration
 * - draftChanges: CV polishing suggestions
 * - generateCoverLetter: tailored cover letter
 */

import { setGlobalOptions } from "firebase-functions/v2";
import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

/** ===== Global options (region/limits) ===== */
setGlobalOptions({
  region: "us-central1",
  maxInstances: 10,
  memory: "512MiB",
  timeoutSeconds: 60,
});

/** ===== Secret (OpenAI API key) ===== */
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

/* =======================================================================
 * 1) draftChanges  — CV polishing (used by PolishCVScreen)
 * =======================================================================
 */
export const draftChanges = onRequest(
  { cors: true, secrets: [OPENAI_API_KEY] },
  async (req, res): Promise<void> => {
    // CORS preflight
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Headers", "content-type, authorization");
      res.status(204).send();
      return;
    }

    // Only POST allowed
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const apiKey = OPENAI_API_KEY.value();
    if (!apiKey) {
      res.status(500).json({ error: "Missing OpenAI API key" });
      return;
    }

    try {
      const { rawText, profile, areas, instruction } = req.body || {};
      if (!rawText || !profile) {
        res.status(400).json({ error: "Missing required fields" });
        return;
      }

      const systemPrompt = `
You are a professional CV/resume editor.
Improve clarity, tone, and impact without inventing facts.

You MUST respond with ONLY valid JSON.

Respond with an object in this shape:
{
  "changes": [
    {
      "id": "string",          // unique id for this suggestion
      "scope": "string",       // e.g. "summary" or "experience[0].bullets[1]"
      "before": "string",      // original text
      "after": "string",       // improved text
      "rationale": "string"    // short explanation of why
    },
    ...
  ]
}

No extra text, no markdown, no comments.
`;

      const userPayload = {
        rawText,
        profile,
        areas,
        instruction,
      };

      const body = {
        model: "gpt-4o-mini",
        temperature: 0.4,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: systemPrompt },
          {
            role: "user",
            content: JSON.stringify(userPayload),
          },
        ],
      };

      const response = await fetch(
        "https://api.openai.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        }
      );

      if (!response.ok) {
        const errText = await response.text();
        logger.error("OpenAI API Error (draftChanges):", errText);
        res.status(response.status).json({ error: errText });
        return;
      }

      const data: any = await response.json();
      const content = data?.choices?.[0]?.message?.content ?? "{}";

      let changes: any[] = [];

      try {
        const parsed = JSON.parse(content);

        // Expected: { changes: [...] }
        if (Array.isArray(parsed?.changes)) {
          changes = parsed.changes;
        }
        // Fallback: bare array
        else if (Array.isArray(parsed)) {
          changes = parsed;
        } else {
          logger.error(
            "Unexpected JSON shape from model (draftChanges):",
            parsed
          );
        }
      } catch (e) {
        logger.error("Invalid JSON from model (draftChanges):", content);
        res.status(502).json({ error: "Invalid JSON response from model" });
        return;
      }

      res.set("Access-Control-Allow-Origin", "*");
      res.json({ changes });
      return;
    } catch (err: any) {
      logger.error("draftChanges error:", err);
      res
        .status(500)
        .json({ error: err?.message || "Unknown error in draftChanges" });
      return;
    }
  }
);

/* =======================================================================
 * 2) generateCoverLetter — cover letter generation
 *    (used by CoverLetterScreen via AiService.generateCoverLetter)
 * =======================================================================
 */
export const generateCoverLetter = onRequest(
  { cors: true, secrets: [OPENAI_API_KEY] },
  async (req, res): Promise<void> => {
    // CORS preflight
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Headers", "content-type, authorization");
      res.status(204).send();
      return;
    }

    // Only POST allowed
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const apiKey = OPENAI_API_KEY.value();
    if (!apiKey) {
      res.status(500).json({ error: "Missing OpenAI API key" });
      return;
    }

    try {
      const { jobTitle, company, description } = req.body || {};

      if (!jobTitle || !company || !description) {
        res.status(400).json({ error: "Missing required fields" });
        return;
      }

      const systemPrompt = `
You are an expert career writer.
Write a professional, tailored cover letter based on the job title, company, and job description.

Rules:
- Use a clear, confident, professional tone.
- Do NOT invent specific fake companies or degrees.
- You MAY infer general strengths and experience from the job description.
- Address it to "Dear Hiring Manager,".
- Keep it around 3–6 short paragraphs.
- NO markdown.

You MUST respond with ONLY valid JSON in this shape:
{
  "letter": "full cover letter text here"
}
`;

      const userPayload = {
        jobTitle,
        company,
        description,
      };

      const body = {
        model: "gpt-4o-mini",
        temperature: 0.7,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: systemPrompt },
          {
            role: "user",
            content: JSON.stringify(userPayload),
          },
        ],
      };

      const response = await fetch(
        "https://api.openai.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        }
      );

      if (!response.ok) {
        const errText = await response.text();
        logger.error("OpenAI API Error (generateCoverLetter):", errText);
        res.status(response.status).json({ error: errText });
        return;
      }

      const data: any = await response.json();
      const content = data?.choices?.[0]?.message?.content ?? "{}";

      let letter = "";

      try {
        const parsed = JSON.parse(content);
        if (typeof parsed?.letter === "string") {
          letter = parsed.letter;
        } else {
          logger.error(
            "Unexpected JSON shape from model (generateCoverLetter):",
            parsed
          );
        }
      } catch (e) {
        logger.error("Invalid JSON from model (generateCoverLetter):", content);
        res.status(502).json({ error: "Invalid JSON response from model" });
        return;
      }

      if (!letter) {
        res.status(502).json({ error: "Empty letter from model" });
        return;
      }

      res.set("Access-Control-Allow-Origin", "*");
      res.json({ letter });
      return;
    } catch (err: any) {
      logger.error("generateCoverLetter error:", err);
      res.status(500).json({
        error: err?.message || "Unknown error in generateCoverLetter",
      });
      return;
    }
  }
);
