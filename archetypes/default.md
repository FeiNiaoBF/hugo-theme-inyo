---
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
date: {{ .Date }}
description: ""
summary: ""
draft: true
math: false
categories: []
{{ site.Params.taxonomy.tag | default "tags" }}: []
---
