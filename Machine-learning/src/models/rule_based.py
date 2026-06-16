from datetime import datetime, timezone
from src.config.constants import (
    FVS_WEIGHTS,
    INDICATOR_NAMES,
    CATEGORY_THRESHOLDS,
)
from src.features.engineer import feature_engineer
from src.schemas.fvs import (
    FvsCalculateResponse,
    FvsCalculateData,
    ExplanationInfo,
)


class RuleBasedFVSCalculator:
    """Calculates FVS using the official weighted formula and new risk categorization."""

    def __init__(self) -> None:
        self.model_version = "rule-v1.0.0"

    @staticmethod
    def _get_category(fvs_score: float) -> str:
        for threshold, category in CATEGORY_THRESHOLDS:
            if fvs_score >= threshold:
                return category
        return "Critical"

    def generate_explanation(self, indicators: dict[str, float], score: float, category: str) -> ExplanationInfo:
        strengths = []
        vulnerabilities = []

        if indicators["emergency_fund_coverage"] >= 70:
            strengths.append("Healthy emergency fund provides a reliable buffer for unexpected expenses.")
        elif indicators["emergency_fund_coverage"] < 40:
            vulnerabilities.append("Critically low or absent emergency fund increases risk during job loss or emergencies.")

        if indicators["debt_burden_ratio"] >= 70:
            strengths.append("Low debt-to-income ratio indicates highly manageable liability levels.")
        elif indicators["debt_burden_ratio"] < 40:
            vulnerabilities.append("High debt burden consumes a significant portion of your monthly income.")

        if indicators["expense_ratio"] >= 70:
            strengths.append("Spending habits are well-controlled and within sustainable limits.")
        elif indicators["expense_ratio"] < 40:
            vulnerabilities.append("Monthly expenditures consume a concerning share of your earnings, reducing surplus.")

        if indicators["protection_readiness"] >= 60:
            strengths.append("Insurance protection levels are adequate relative to annual income.")
        elif indicators["protection_readiness"] < 30:
            vulnerabilities.append("Minimal insurance coverage leaves you exposed to health or life disruptions.")

        if indicators["shock_absorption_capacity"] >= 70:
            strengths.append("Strong monthly cash surplus allows for high shock absorption.")
        elif indicators["shock_absorption_capacity"] < 40:
            vulnerabilities.append("Negligible monthly surplus limits your ability to absorb any immediate financial shocks.")

        # Default explanation summary based on category
        if category == "Safe":
            summary = f"Your financial profile is resilient with a score of {score:.1f}. Maintain your healthy savings and low debt levels."
        elif category == "Moderate":
            summary = f"Your financial health is stable with a score of {score:.1f}, but minor vulnerabilities exist. Focus on building your emergency savings."
        elif category == "Warning":
            summary = f"Your financial profile shows significant warnings with a score of {score:.1f}. Take action to reduce expenses and limit debt."
        else:
            summary = f"Your financial profile is in a Critical state with a score of {score:.1f}. High debt or lack of a safety net demands immediate intervention."

        return ExplanationInfo(
            summary=summary,
            strengths=strengths if strengths else ["No major financial strengths identified yet."],
            vulnerabilities=vulnerabilities if vulnerabilities else ["No major financial vulnerabilities identified."]
        )

    def calculate(
        self,
        monthly_income: float,
        monthly_expenses: float,
        total_debt: float,
        number_of_dependents: int,
        protection_coverage: float,
        emergency_fund: float,
    ) -> FvsCalculateResponse:
        indicators = feature_engineer.compute_all(
            monthly_income=monthly_income,
            monthly_expenses=monthly_expenses,
            total_debt=total_debt,
            number_of_dependents=number_of_dependents,
            protection_coverage=protection_coverage,
            emergency_fund=emergency_fund,
        )

        fvs_score = sum(indicators[name] * FVS_WEIGHTS[name] for name in INDICATOR_NAMES)
        fvs_score = round(min(max(fvs_score, 0), 100), 2)
        category = self._get_category(fvs_score)

        explanation = self.generate_explanation(indicators, fvs_score, category)

        # Baseline feature importance for rule-based engine is just the weight values
        feature_importance = {name: FVS_WEIGHTS[name] for name in INDICATOR_NAMES}

        return FvsCalculateResponse(
            success=True,
            model_version=self.model_version,
            data=FvsCalculateData(
                score=fvs_score,
                category=category,
                indicators=indicators,
                feature_importance=feature_importance,
                explanation=explanation,
            ),
        )


rule_based_calculator = RuleBasedFVSCalculator()
