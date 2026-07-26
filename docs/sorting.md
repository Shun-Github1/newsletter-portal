# Newsletter Portal Sorting & Tagging System

This document describes the two-tiered tagging and sorting architecture for the Newsletter Portal.

---

## 1. Overview

The portal utilizes a hybrid relevance calculation combining user preferences (Sectors and Regions) with dynamic tags and system relevance scores.

---

## 2. Preference-Based Feed Sorting (Tier 1)

Tagging by default is done using preset fixed options, for which users set preferences (weighted 1 to 5) on initiation. These preferences cover **Sectors** and **Regions**.

### Relevance Score Calculation
The user relevance score for each news event is calculated as:
$$\text{Relevance Score} = \text{Sector Relevance} \times \text{Region Relevance} \times \text{Tag Relevance}$$

- **Sector Relevance**: Weighted sum of matched sectors divided by total sector weight.
- **Region Relevance**: Matched region weight divided by total region weight.
- **Tag Relevance**: Matching topic tag multiplier.

---

## 3. Dynamic Tagging & Feeds (Tier 2)

Dynamic feed items are automatically prioritized in the user feed, internally sorted based on the calculations above.
- For each event, up to five dynamic tags are generated from relevant Public Figures, Companies, Institutions, or Locations.
- For consistency, entity titles are mapped using supported multilingual locales (`en-UK`, `zh-HK`, `zh-CN`).

---

## 4. Standardized Options Reference

### Sectors (16 Canonical Sectors)
| ID | Sector Name | Classification |
| :--- | :--- | :--- |
| **1** | Politics & Government | Hard Sector |
| **2** | Business & Economy | Hard Sector |
| **3** | Conflict / Military | Hard Sector |
| **4** | Crime & Justice | Hard Sector |
| **5** | Technology | Hard Sector |
| **6** | Environment & Climate | Hard Sector |
| **7** | Weather | Hard Sector |
| **8** | Real Estate | Hard Sector |
| **9** | Science | Soft Sector |
| **10** | Health & Medicine | Soft Sector |
| **11** | Education | Soft Sector |
| **12** | Sports | Soft Sector |
| **13** | Arts & Entertainment | Soft Sector |
| **14** | Lifestyle & Culture | Soft Sector |
| **15** | Religion & Ethics | Soft Sector |
| **16** | Opinion & Commentary | Soft Sector |

### Regions (6 Portal Regions)
| Tag | Display Name |
| :--- | :--- |
| `hk` | Hong Kong SAR |
| `china` | Mainland China |
| `uk` | United Kingdom |
| `usa` | United States of America |
| `asia-others` | Asia (others) |
| `europe-others` | Europe (others) |

### Supported Languages
| Code | Language | Fallback |
| :--- | :--- | :--- |
| `en-UK` | English (UK) *(default)* | `en-US` → `en-UK` |
| `zh-HK` | Traditional Chinese (Hong Kong) | `zh-TW` → `zh-HK` |
| `zh-CN` | Simplified Chinese | — |

### Feed Sorting Modes
| Mode | Description |
| :--- | :--- |
| `latest` | Sorted by publish date (newest first) *(default)* |
| `popular` | Sorted by source count and engagement |
| `relevant` | Sorted by compute relevance score |

