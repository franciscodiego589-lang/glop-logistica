import dns from "node:dns/promises";
import net from "node:net";

// Proteção anti-SSRF: só permite https para hosts PÚBLICOS. Bloqueia loopback,
// redes privadas, link-local (inclui metadata 169.254.169.254), CGNAT e IPv6
// interno. Resolve o DNS e checa os IPs resolvidos.
function isPrivateIp(ip: string): boolean {
  if (net.isIPv4(ip)) {
    const p = ip.split(".").map(Number);
    return (
      p[0] === 0 || p[0] === 127 || p[0] === 10 ||
      (p[0] === 172 && p[1] >= 16 && p[1] <= 31) ||
      (p[0] === 192 && p[1] === 168) ||
      (p[0] === 169 && p[1] === 254) ||          // link-local + metadata cloud
      (p[0] === 100 && p[1] >= 64 && p[1] <= 127) // CGNAT
    );
  }
  if (net.isIPv6(ip)) {
    const l = ip.toLowerCase().replace(/^\[|\]$/g, "");
    return (
      l === "::1" || l === "::" ||
      l.startsWith("fc") || l.startsWith("fd") ||     // unique-local
      l.startsWith("fe80") ||                          // link-local
      l.startsWith("::ffff:127.") || l.startsWith("::ffff:10.") ||
      l.startsWith("::ffff:192.168.") || l.startsWith("::ffff:169.254.") ||
      l.startsWith("::ffff:172.")
    );
  }
  return true; // desconhecido → bloqueia
}

export async function assertPublicHttpsUrl(raw: string): Promise<URL> {
  let u: URL;
  try { u = new URL(raw); } catch { throw new Error("Base URL inválida."); }
  if (u.protocol !== "https:") throw new Error("Base URL deve usar https.");
  const host = u.hostname.toLowerCase();
  if (host === "localhost" || host.endsWith(".local") || host.endsWith(".internal") ||
      host === "metadata.google.internal" || net.isIP(host) && isPrivateIp(host)) {
    throw new Error("Host não permitido (interno).");
  }
  let addrs: { address: string }[];
  try { addrs = await dns.lookup(host, { all: true }); }
  catch { throw new Error("Host não pôde ser resolvido."); }
  for (const a of addrs) if (isPrivateIp(a.address)) throw new Error("Host aponta para rede interna — bloqueado (SSRF).");
  return u;
}
