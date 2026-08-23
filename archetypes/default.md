---
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
layout: post
date: {{ .Date }}
description: ""
summary: ""
draft: true
math: false
categories: []
{{ site.Params.taxonomy.tag | default "tags" }}: []
---
