// Fabbit 멀티테넌트 와일드카드 서브도메인 라우터
// *.fabbitinc.com 요청을 Pages SPA로 프록시

const PAGES_ORIGIN = "${pages_origin}";

// 예약 서브도메인 — Worker가 처리하지 않고 passthrough
const RESERVED_SUBDOMAINS = new Set([
  "www", // 랜딩 페이지
  "api", // 백엔드 API
  "api-dev", // 백엔드 API (dev)
  "cdn", // R2 커스텀 도메인
]);

addEventListener("fetch", (event) => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  const url = new URL(request.url);
  const subdomain = url.hostname.split(".")[0];

  // 예약 서브도메인 → passthrough
  if (RESERVED_SUBDOMAINS.has(subdomain)) {
    return fetch(request);
  }

  // Pages origin에서 SPA fetch
  const originUrl = PAGES_ORIGIN + url.pathname + url.search;
  let response = await fetch(originUrl, {
    method: request.method,
    headers: request.headers,
  });

  // SPA 라우팅: 404 + 확장자 없는 경로 → /index.html 반환
  if (response.status === 404 && !hasExtension(url.pathname)) {
    response = await fetch(PAGES_ORIGIN + "/index.html");
  }

  // 응답 복제 후 커스텀 헤더 추가
  const newResponse = new Response(response.body, response);
  newResponse.headers.set("X-Served-By", "fabbit-worker");
  return newResponse;
}

// 경로에 파일 확장자가 있는지 확인
function hasExtension(pathname) {
  const lastSegment = pathname.split("/").pop();
  return lastSegment.includes(".");
}
