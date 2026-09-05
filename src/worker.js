function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

async function handlePost(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return jsonResponse({ error: "invalid JSON" }, 400);
  }

  const nickname = typeof body.nickname === "string" ? body.nickname.trim().slice(0, 50) : "";
  const satisfaction = Number(body.satisfaction);
  const comment = typeof body.comment === "string" ? body.comment.trim().slice(0, 2000) : "";

  if (!nickname) {
    return jsonResponse({ error: "ニックネームを入力してください" }, 400);
  }
  if (!Number.isInteger(satisfaction) || satisfaction < 1 || satisfaction > 5) {
    return jsonResponse({ error: "満足度は1〜5で選択してください" }, 400);
  }

  await env.DB.prepare(
    "INSERT INTO responses (nickname, satisfaction, comment, created_at) VALUES (?, ?, ?, ?)"
  )
    .bind(nickname, satisfaction, comment, new Date().toISOString())
    .run();

  return jsonResponse({ ok: true });
}

async function handleGet(env) {
  const { results } = await env.DB.prepare(
    "SELECT id, nickname, satisfaction, comment, created_at FROM responses ORDER BY id DESC"
  ).all();
  return jsonResponse({ results });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/api/responses") {
      if (request.method === "POST") return handlePost(request, env);
      if (request.method === "GET") return handleGet(env);
      return jsonResponse({ error: "method not allowed" }, 405);
    }

    return env.ASSETS.fetch(request);
  },
};
