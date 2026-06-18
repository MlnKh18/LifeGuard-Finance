# Stitch → Flutter Mapping & Gap Analysis

Source: Stitch project `10086180151253735914` ("Lifeguard Mobile Design System"), screens listed in `stitch-mcp.md`. Compared against the current implementation in `lib/features/**`.

## Screen-by-screen mapping

| # | Stitch screen | Stitch file | Flutter file | Status |
|---|---|---|---|---|
| 1 | Komunitas (Light) - Logo Update | `komunitas_light_logo_update.html` | `features/community/presentation/pages/community_page.dart` | **Rebuilt from scratch** — `CommunityCubit` was a stub no-op (`Cubit<int>`); built `CommunityPost`/`CommunityChallenge`/`CommunityProgress` entities + Hive-persisted cubit (toggle like, add post, progress challenge), profile/XP summary card, discussion feed with like/comment counts, primary + minor challenge cards, FAB to post a new discussion |
| 2 | Deteksi Anomali (Light) - Logo Update | `deteksi_anomali_light_logo_update.html` | `features/anomaly_detection/presentation/pages/expense_anomaly_page.dart` | **Rebuilt from scratch** — `AnomalyDetectionService` was an empty class and `AnomalyCubit`/`ExpenseCubit` were both stub no-ops (`Cubit<int>`, and duplicates of each other — `ExpenseCubit` deleted as dead code); built real `ExpenseTransaction`/`MonthlyExpenseTrend` entities, a Hive-persisted cubit, and an actual local Z-score anomaly detector (per-category transaction outliers + monthly total outliers), `fl_chart`-based trend chart with highlighted outlier point, anomaly-tagged transaction list, FAB to add transactions |
| 3 | Rencana Mitigasi (Light) - Logo Update | `rencana_mitigasi_light_logo_update.html` | `features/recommendation/presentation/pages/recommendation_page.dart` | **Rebuilt from scratch** — `RecommendationCubit`/`RecommendationGenerator` were stub no-ops (`Cubit<int>`, empty class); built a real S2/S3/S4/S6-driven rule engine + Hive-persisted checklist, 30/60/90-day tabs, progress bar, custom task dialog |
| 4 | Pos Dana Darurat (Light) - Logo Update | `pos_dana_darurat_light_logo_update.html` | `features/savings_vault/presentation/pages/savings_vault_page.dart` | **Rebuilt from scratch** — `VaultCubit` was a stub no-op (`Cubit<int>`); built a real `SavingsVault` entity + Hive-persisted cubit (create vault, add funds), summary header (total saved), per-vault progress-ring cards with "+ Tabung"/"Completed" states, FAB to add new vaults |
| 5 | Simulasi Sandbox (Light) - Logo Update | `simulasi_sandbox_light_logo_update.html` | `features/emergency_simulation/presentation/pages/simulation_page.dart` | **Rebuilt** — scenario chips (all 6 types, Stitch only mocked 3), parameter slider, before/after score rings, vertical stat tiles (Runway/Defisit/Sisa Dana Darurat) |
| 6 | Dashboard Utama (Light) - Logo Update | `dashboard_utama_light_logo_update.html` | `features/fvs_dashboard/presentation/pages/dashboard_page.dart` | **Rebuilt** — score card with status pill, 2x2 metric bento grid (computed live from profile), feature-link cards, primary CTA |
| 7 | Splash Screen (Light) - Logo Update | `splash_screen_light_logo_update.html` | `features/splash/presentation/pages/splash_page.dart` | **Placeholder only** — plain icon + text, no logo asset, no gradient/branding from Stitch |
| 8 | Onboarding - Step 1 (Refined UI/UX) | `onboarding_step1_refined_ui_ux.html` | `features/onboarding/presentation/pages/onboarding_page.dart` | **Placeholder only** — single static page, no multi-step carousel (Stitch has Step 1/2/3) |

## Structural gap: no persistent bottom navigation

Every Stitch screen (Dashboard, Komunitas, Mitigasi, Sandbox, Vault) assumes a **persistent bottom nav bar** with up to 5 tabs (Komunitas, Ringkasan/Dashboard, Sandbox, Mitigasi, Profil) plus a contextual FAB on some screens (e.g. "+" on Komunitas).

The current app has **no shell/bottom nav at all** — `app_router.dart` defines each page as a standalone top-level `GoRoute`, navigated to via `context.push`/`context.go`. This is the single biggest structural gap: it affects all 5 main screens identically and should be fixed once via a shared shell (e.g. `StatefulShellRoute.indexedStack` in go_router) rather than per-screen.

## Color token mismatch

Stitch's light-mode tokens (Material 3-derived) vs current `AppColors`:

| Token | Stitch (Light) | Current `AppColors` | Notes |
|---|---|---|---|
| primary | `#00685f` | `#0F766E` | Close but not identical |
| background | `#f5faf8` | `#FAFAFA` | Stitch has a slight teal tint |
| surface | `#f5faf8` (`surface-container-lowest: #ffffff`) | `#FFFFFF` | Roughly aligned |
| border | `#E2E8F0` | `#E2E8F0` | **Exact match** |
| error/critical | `#ba1a1a` (Stitch error) vs `#EF4444` (Stitch status-critical) | `#EF4444` | Current matches Stitch's separate "status-critical" semantic token, not its Material `error` token — keep as is, it's the more correct semantic choice |
| font family | Outfit (headings/body) + Inter (numeric data) | System default (no custom font declared) | **Missing** — no `Outfit`/`Inter` fonts wired into `pubspec.yaml`/`AppTheme` |

## Confirmed Stitch generation bugs (not to be copied into Flutter)

1. **Wrong active nav state, repeated on 3 screens** — in `komunitas_light_logo_update.html` (lines ~279-294), the "Komunitas" tab text is colored `text-primary` (implying selected), but the actual filled/active pill styling (`bg-primary-container` + icon `FILL 1`) is applied to the **"Mitigasi"** tab instead. Same bug shows up again in `rencana_mitigasi_light_logo_update.html`: while viewing the Mitigasi page, the **"Sandbox"** tab is the one styled active (`text-[#0D9488]` + `FILL 1`), not Mitigasi. And again in `pos_dana_darurat_light_logo_update.html`: while viewing the Vault page, **"Mitigasi"** is the tab styled active (`bg-primary-container` + shield icon `FILL 1`), not Vault (which isn't even in the 4-tab set on this screen — see bug #2). Confirms the mockups' nav state was never meant to be copied literally — `MainShell` derives the active tab from the actual route instead.
2. **Inconsistent nav tab count across screens** — `dashboard_utama_light_logo_update.html`, `simulasi_sandbox_light_logo_update.html`, and `pos_dana_darurat_light_logo_update.html` all only render 4 nav tabs (Ringkasan, Sandbox, Mitigasi, Profil) and are missing the "Komunitas" tab entirely, while `komunitas_light_logo_update.html` renders all 5. Treat 5 tabs (Komunitas, Ringkasan, Sandbox, Mitigasi, Profil) as the canonical set for the shared shell — already implemented this way in `MainShell`.
3. **Fabricated trend stat with no backing data** — `pos_dana_darurat_light_logo_update.html` shows a "+2.5% vs Last Month" trend pill under the total funds figure, but the app has no time-series/snapshot history for vault balances to compute a real month-over-month delta. Rather than fabricate a number, the Flutter rebuild omits this pill entirely and shows just the total.
4. **External placeholder avatar images** — `komunitas_light_logo_update.html` hardcodes `lh3.googleusercontent.com` URLs for user/post avatars (Stitch-generated mock photography). The app has no real photo upload feature, so these wouldn't resolve to anything meaningful at runtime; the Flutter rebuild uses initials-on-color `CircleAvatar`s instead (matching the one place the mockup itself already does this as a fallback, Reza K.'s "R" avatar).
5. **4th wrong-active-tab instance, on a screen outside the 5-tab set** — `deteksi_anomali_light_logo_update.html`'s mobile bottom nav highlights **"Ringkasan"** as active (`bg-primary-container`) while viewing the Insights/Deteksi Anomali page — itself not even one of the 4 tabs rendered (the desktop side nav correctly highlights "Insights" instead, so only the mobile nav mock has the bug). Deteksi Anomali is reached via a feature-link push from Dashboard, not a shell tab, so this is moot for the Flutter app, but recorded for completeness.
6. **Unrealistic Rupiah magnitudes** — `deteksi_anomali_light_logo_update.html`'s transaction list shows amounts like "Rp142.50" and "Rp2,450.00" — USD-style cents formatting mistakenly applied to Rupiah labels. Real Indonesian household expenses (groceries, electronics) run into the hundreds-of-thousands to millions. The Flutter rebuild uses realistic seed amounts (e.g. Rp 1.850.000 for groceries, Rp 12.450.000 for the anomalous electronics purchase) instead of copying the mockup's figures verbatim.

## Recommended next steps (not yet implemented)

1. Add `Outfit` + `Inter` fonts to `pubspec.yaml` and wire into `AppTheme`/`AppTextStyles`.
2. Align `AppColors` light palette to the Stitch tokens above.
3. Introduce a `StatefulShellRoute` with the 5 canonical tabs (Komunitas, Ringkasan, Sandbox, Mitigasi, Profil) in `app_router.dart`, replacing the flat route list for these 5 screens.
4. Rebuild each screen's body to match its Stitch HTML structure, screen by screen, reusing `AppCard`/`PrimaryButton`/`SectionTitle` where they already fit and extending them (e.g. a new `CircularGaugeChart` widget for the FVS donut, a `MetricBentoCard` for the dashboard grid) where Stitch introduces new patterns.
