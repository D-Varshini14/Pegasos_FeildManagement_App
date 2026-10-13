import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography system using Inter font family.
/// Inspired by Linear, Stripe, Vercel, and Notion typography standards.
///
/// Usage: `style: AppTypography.pageTitle.copyWith(color: Colors.white)`
class AppTypography {
  AppTypography._(); // Prevent instantiation

  // ─── Display ───────────────────────────────────────────────
  /// 48px / ExtraBold — Hero text, onboarding headlines
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.5,
      );

  // ─── Page Title ────────────────────────────────────────────
  /// 32px / Bold — Top-level page headings (Welcome, Dashboard)
  static TextStyle get pageTitle => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
      );

  // ─── Section Heading ───────────────────────────────────────
  /// 24px / SemiBold — Section dividers within a page
  static TextStyle get sectionHeading => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  // ─── Card Title ────────────────────────────────────────────
  /// 18px / SemiBold — Card headers, dialog titles
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.15,
      );

  // ─── Body ──────────────────────────────────────────────────
  /// 16px / Regular — Primary body text
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  /// 16px / Medium — Slightly emphasized body text
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
      );

  // ─── Secondary ─────────────────────────────────────────────
  /// 14px / Regular — Supporting text, descriptions
  static TextStyle get secondary => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  /// 14px / Medium — Emphasized secondary (input text, links)
  static TextStyle get secondaryMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
      );

  // ─── Caption ───────────────────────────────────────────────
  /// 12px / Regular — Timestamps, metadata, small labels
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
      );

  /// 12px / Medium — Nav labels, emphasized captions
  static TextStyle get captionMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
      );

  // ─── Overline / Badge ──────────────────────────────────────
  /// 10px / SemiBold — Status badges, chips, tags
  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.5,
      );

  // ─── Buttons ───────────────────────────────────────────────
  /// 16px / SemiBold — Primary CTA buttons
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0,
      );

  /// 14px / SemiBold — Secondary buttons
  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0,
      );

  /// 12px / Medium — Small action buttons, inline actions
  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0,
      );

  // ─── KPI / Stats ───────────────────────────────────────────
  /// 24px / Bold — Large stat numbers
  static TextStyle get kpiValue => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
      );

  /// 12px / SemiBold — Stat labels beneath numbers
  static TextStyle get kpiLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.2,
      );

  // ─── Form ──────────────────────────────────────────────────
  /// 14px / Medium — Form field labels
  static TextStyle get formLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  /// 15px / Medium — Input text value
  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  /// 14px / Regular — Placeholder/hint text
  static TextStyle get hint => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
      );

  // ─── Alerts & Messages ─────────────────────────────────────
  /// 12px / Regular — Alert body, error messages
  static TextStyle get alertText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
      );

  /// 13px / Regular — Slightly larger alert/description text
  static TextStyle get alertDescription => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
      );

  /// 14px / Medium — Snackbar / toast content
  static TextStyle get snackbar => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  // ─── Empty States ──────────────────────────────────────────
  /// 20px / SemiBold — Empty state headings
  static TextStyle get emptyStateTitle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.15,
      );

  /// 14px / Regular — Empty state descriptions
  static TextStyle get emptyStateBody => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0,
      );

  // ─── Brand / Splash ────────────────────────────────────────
  /// 38px / Bold — App name on splash screen
  static TextStyle get appName => GoogleFonts.inter(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 0.5,
      );

  /// 16px / Medium — Splash tagline (wide letter spacing)
  static TextStyle get tagline => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 2.4,
      );

  // ─── Navigation ────────────────────────────────────────────
  /// 28px / SemiBold — AppBar / top bar title
  static TextStyle get appBarTitle => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.3,
      );

  /// 12px / SemiBold — Selected bottom nav label
  static TextStyle get navLabelSelected => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0,
      );

  /// 12px / Medium — Unselected bottom nav label
  static TextStyle get navLabelUnselected => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0,
      );

  // ─── Dialog ────────────────────────────────────────────────
  /// 18px / Bold — Dialog/modal title
  static TextStyle get dialogTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.1,
      );

  /// 14px / Regular — Dialog body text
  static TextStyle get dialogBody => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  // ─── Table ─────────────────────────────────────────────────
  /// 12px / SemiBold — Table column headers
  static TextStyle get tableHeader => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.2,
      );

  /// 13px / Regular — Table cell content
  static TextStyle get tableCell => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
      );

  /// 13px / Medium — Table cell with emphasis
  static TextStyle get tableCellMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      );

  // ─── Notification Badge ────────────────────────────────────
  /// 9px / Bold — Notification count badge
  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0,
      );

  // ─── OTP / Monospace ───────────────────────────────────────
  /// 20px / Bold — OTP entry field (monospace, stays Roboto Mono)
  static TextStyle get otpCode => GoogleFonts.robotoMono(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 8,
      );

  // ─── Welcome Subtitle ─────────────────────────────────────
  /// 26px / Bold — Login screen welcome heading
  static TextStyle get welcomeTitle => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
      );

  /// 14px / Regular — Login screen subtitle
  static TextStyle get welcomeSubtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  // ─── Login Brand ───────────────────────────────────────────
  /// 32px / ExtraBold — Brand name on login screen
  static TextStyle get loginBrand => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.3,
      );

  /// 14px / Regular — Brand subtitle on login
  static TextStyle get loginSubBrand => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
      );

  // ─── Link Text ─────────────────────────────────────────────
  /// 13px / SemiBold — Inline link / action text
  static TextStyle get link => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  /// 14px / SemiBold — Prominent inline link
  static TextStyle get linkProminent => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  // ─── Misc ──────────────────────────────────────────────────
  /// 11px / Medium — Very small text (locked task labels, etc.)
  static TextStyle get micro => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0,
      );

  /// 12px / Bold — Countdown / timer emphasis
  static TextStyle get timerText => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0,
      );

  /// 12px / Bold + underline — Resend code action
  static TextStyle get resendAction => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
      );
}
