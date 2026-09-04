# Etapa 5 — DNS

## Objetivo

Configurar um domínio personalizado para o currículo e disponibilizá-lo através de HTTPS utilizando Amazon CloudFront, AWS Certificate Manager (ACM) e Cloudflare DNS.

## Serviços utilizados

- Amazon CloudFront
- AWS Certificate Manager (ACM)
- Cloudflare DNS
- Amazon S3

## Passo a passo

1. Utilizei o domínio `barrosamorimd.work` para o projeto.
2. Solicitei um certificado SSL/TLS para o domínio através do AWS Certificate Manager, utilizando a região `us-east-1`, necessária para utilização do certificado com o CloudFront.
3. O ACM forneceu um registro CNAME para validação do domínio.
4. Criei o registro CNAME de validação no Cloudflare e configurei como **DNS Only**.
5. Realizei verificações de DNS para confirmar se o registro de validação estava sendo publicado corretamente pelos servidores autoritativos do Cloudflare.
6. Após a validação, o certificado foi emitido pelo ACM.
7. Configurei `barrosamorimd.work` como **Alternate domain name (CNAME)** na distribuição do Amazon CloudFront.
8. Associei o certificado SSL/TLS emitido pelo ACM à distribuição CloudFront.
9. Configurei a política de segurança TLS da distribuição como `TLSv1.2_2021`.
10. Criei no Cloudflare o registro CNAME principal do domínio, apontando `barrosamorimd.work` → `d189fig617ch0u.cloudfront.net`.
11. Mantive o registro como **DNS Only**, permitindo que o DNS do Cloudflare apenas direcionasse o domínio para o CloudFront.
12. Durante a configuração, o domínio apresentou inicialmente o erro `DNS_PROBE_FINISHED_NXDOMAIN`.
13. Utilizei o comando `nslookup` para investigar a resolução DNS: `nslookup barrosamorimd.work 1.1.1.1`
14. O teste confirmou que o domínio estava sendo resolvido corretamente para a infraestrutura do CloudFront.
15. Realizei o teste final acessando `https://barrosamorimd.work`.

## Arquitetura

```
Usuário
   │
   │ HTTPS
   ▼
barrosamorimd.work
   │
   │ DNS / CNAME
   ▼
Amazon CloudFront
   │
   │ HTTP
   ▼
Amazon S3
   │
   ├── index.html
   └── style.css
```

## Troubleshooting

Durante a configuração do domínio, o acesso apresentou inicialmente:

```
DNS_PROBE_FINISHED_NXDOMAIN
```

O problema foi investigado utilizando `nslookup` e consultas aos registros DNS.

Após a configuração correta do CNAME do domínio para a distribuição CloudFront, a resolução DNS passou a funcionar:

```
barrosamorimd.work → d189fig617ch0u.cloudfront.net
```

O acesso HTTPS foi então validado com sucesso.

## Resultado

O currículo passou a estar disponível através de um domínio personalizado e protegido por HTTPS.

**URL do projeto:** `https://barrosamorimd.work`

A configuração demonstra a utilização integrada de **DNS, certificado SSL/TLS, CloudFront e S3**, incluindo diagnóstico e resolução de problemas de DNS.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
