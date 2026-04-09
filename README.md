# NewsFeed

A premium cross-platform Flutter application providing highly curated, real-time localized news articles powered by an intelligent AI integration. 

---

## 🛑 The Problem
In today’s fast-paced digital era, we are constantly bombarded with endless streams of news across varying categories and countries. This creates two distinct pain points for users:
1. **Information Overload**: Reading massive blocks of journalism just to understand the baseline concept of a news story is incredibly time-consuming.
2. **Poor Locality**: Mainstream algorithms often fail to provide tightly categorized, country-specific breaking news dynamically in an aesthetic, unified interface.

## 💡 Our Solution
**NewsFeed** directly combats modern journalistic overload by unifying powerful categorization with Artificial Intelligence. 
Built natively in Flutter, it acts as a globalized news hub that lets you instantly traverse borders, filter through strict news verticals (Technology, Business, Sports, etc.), and intelligently **summarize** any extensive article into a short, digestible highlight using AI Models—all mapped within a sleek, deeply responsive layout.

---

## 🌟 Core Features

- **Global Coverage Mapping**: Dynamically flip through 36 different global country metrics. Switch from United States headlines to Japanese tech news with a single dropdown modification.
- **Categorical Segregation**: Smooth, modern navigation seamlessly partitions your feed into exact categories (World, Business, Politics, Entertainment, Technology, and Sports).
- **Intelligent Right-Panel AI Summarizer**: By tapping the "Sparkle" icon positioned on every news card, a highly responsive right-side drawer slides flawlessly into view, utilizing AI Models to read the article's descriptions and build localized, rapid-fire executive summaries so you get the news faster than ever.
- **Secure Supabase Authentication**: Utilizes a hardened backend connection allowing users to natively register accounts. Upon registration, their localized `Country` preferences are explicitly saved into a custom Postgres table ensuring stateful persistence across sessions.
- **Ultra-Responsive Layout**: Built with a "Mobile-First but Desktop-Ready" responsive strategy utilizing constrained layouts to keep the UI from breaking on ultra-wide monitors while staying beautifully snug on mobile displays.

---

## 🛠️ Technology Stack

- **Frontend**: Flutter & Dart (Cross-Platform compatibility)
- **Backend/Auth**: Supabase (`supabase_flutter`)


---

## 📱 Interface Previews
- **Landing Hero**: Deep gradient background introducing the application features dynamically.
- **Global Auth Screen**: Context-switching login/registration cards natively tied to the custom SQL logic. 
- **Slide-In Drawers**: Smooth-animated `SlideTransition` windows invoking AI data mapping logic over your main page Scaffold.