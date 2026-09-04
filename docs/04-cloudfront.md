# Etapa 4 — HTTPS com Amazon CloudFront

## Objetivo

Disponibilizar o currículo através de HTTPS utilizando o Amazon CloudFront, conforme solicitado pelo Cloud Resume Challenge.

## Configuração

Foi criada uma distribuição do Amazon CloudFront para entregar o conteúdo do site hospedado no Amazon S3.

Configurações utilizadas:

- Distribution name: `cloud-resume-challenge`
- Plano: `Free ($0/month)`
- Origem: S3 Static Website
- S3 Website Endpoint: `cloud-resume-rafael-2026.s3-website-us-east-1.amazonaws.com`
- Origin Shield: desativado
- Cache: configurações recomendadas para conteúdo S3
- WAF: configurações padrão
- HTTPS: habilitado pelo CloudFront

## Problema encontrado

Após criar a distribuição, o acesso pelo CloudFront retornava:

```
403 Forbidden
Code: AccessDenied
Message: Access Denied
```

A mesma situação também ocorria inicialmente ao acessar o Static Website do S3.

## Diagnóstico

O bucket estava com a opção **Bloquear todo o acesso público** ativada.

Como a implementação desta etapa utiliza o endpoint de **Static Website Hosting do S3**, foi necessário permitir acesso público de leitura aos objetos do bucket.

## Solução

Foi desativado o bloqueio de acesso público do bucket e criada uma Bucket Policy permitindo somente a ação:

```
s3:GetObject
```

para os objetos armazenados no bucket.

A política permite leitura pública dos arquivos necessários para o funcionamento do currículo, sem conceder permissões de upload, alteração ou exclusão.

## Testes realizados

1. Acesso ao endpoint do Static Website do S3: currículo carregado com sucesso.
2. Acesso através do CloudFront (`https://d189fig617ch0u.cloudfront.net`): currículo carregado com sucesso.
3. HTTPS: conexão HTTPS funcionando corretamente através do CloudFront.

## Arquitetura

```
Usuário
   |
   | HTTPS
   v
Amazon CloudFront
   |
   | HTTP
   v
Amazon S3
Static Website Hosting
   |
   v
index.html + style.css
```

> Observação: o endpoint de Static Website do S3 utiliza HTTP. O HTTPS para o usuário final é fornecido pelo CloudFront.

## Status

**Concluído ✅**

---

[⬅ Voltar ao README](../README.md)
