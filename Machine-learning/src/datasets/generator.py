import numpy as np
import pandas as pd

from src.config.constants import (
    TRAINING_SAMPLE_SIZE,
    RANDOM_STATE,
)
from src.features.engineer import feature_engineer
from src.models.rule_based import rule_based_calculator


class SyntheticDataGenerator:
    """Generates synthetic Indonesian financial profiles, computes derived indicators, and ground-truth FVS."""

    def __init__(self, n_samples: int = TRAINING_SAMPLE_SIZE, seed: int = RANDOM_STATE) -> None:
        self.n_samples = n_samples
        self.rng = np.random.default_rng(seed)

    def generate(self) -> pd.DataFrame:
        records = []
        # Generate samples across 4 tiers: 0=Critical, 1=Warning, 2=Moderate, 3=Safe
        samples_per_tier = self.n_samples // 4

        for tier in range(4):
            for _ in range(samples_per_tier):
                records.append(self._generate_profile(tier))

        remaining = self.n_samples - len(records)
        for _ in range(remaining):
            tier = self.rng.integers(0, 4)
            records.append(self._generate_profile(tier))

        df = pd.DataFrame(records)
        df = df.sample(frac=1, random_state=RANDOM_STATE).reset_index(drop=True)
        return df

    def _generate_profile(self, tier: int) -> dict:
        # tier 0: Critical, tier 1: Warning, tier 2: Moderate, tier 3: Safe
        if tier == 0:  # Critical
            monthly_income = self.rng.uniform(2_000_000, 4_500_000)
            monthly_expenses = monthly_income * self.rng.uniform(0.8, 1.2)
            total_debt = monthly_income * self.rng.uniform(5.0, 15.0)
            number_of_dependents = self.rng.integers(3, 6)
            protection_coverage = self.rng.uniform(0, 10_000_000)
            emergency_fund = self.rng.uniform(0, 2_000_000)
        elif tier == 1:  # Warning
            monthly_income = self.rng.uniform(4_500_000, 7_000_000)
            monthly_expenses = monthly_income * self.rng.uniform(0.6, 0.85)
            total_debt = monthly_income * self.rng.uniform(2.0, 6.0)
            number_of_dependents = self.rng.integers(2, 4)
            protection_coverage = monthly_income * 12 * self.rng.uniform(0.2, 1.0)
            emergency_fund = monthly_expenses * self.rng.uniform(0.5, 2.0)
        elif tier == 2:  # Moderate
            monthly_income = self.rng.uniform(7_000_000, 15_000_000)
            monthly_expenses = monthly_income * self.rng.uniform(0.4, 0.6)
            total_debt = monthly_income * self.rng.uniform(0.5, 3.0)
            number_of_dependents = self.rng.integers(1, 3)
            protection_coverage = monthly_income * 12 * self.rng.uniform(1.0, 3.0)
            emergency_fund = monthly_expenses * self.rng.uniform(2.0, 5.0)
        else:  # Safe
            monthly_income = self.rng.uniform(15_000_000, 40_000_000)
            monthly_expenses = monthly_income * self.rng.uniform(0.2, 0.4)
            total_debt = monthly_income * self.rng.uniform(0.0, 1.0)
            number_of_dependents = self.rng.integers(0, 2)
            protection_coverage = monthly_income * 12 * self.rng.uniform(3.0, 6.0)
            emergency_fund = monthly_expenses * self.rng.uniform(6.0, 12.0)

        # Clean/Round values for readability
        monthly_income = float(round(monthly_income, -3))
        monthly_expenses = float(round(monthly_expenses, -3))
        total_debt = float(round(total_debt, -3))
        protection_coverage = float(round(protection_coverage, -3))
        emergency_fund = float(round(emergency_fund, -3))

        # Calculate derived indicators
        indicators = feature_engineer.compute_all(
            monthly_income=monthly_income,
            monthly_expenses=monthly_expenses,
            total_debt=total_debt,
            number_of_dependents=number_of_dependents,
            protection_coverage=protection_coverage,
            emergency_fund=emergency_fund,
        )

        res = rule_based_calculator.calculate(
            monthly_income=monthly_income,
            monthly_expenses=monthly_expenses,
            total_debt=total_debt,
            number_of_dependents=number_of_dependents,
            protection_coverage=protection_coverage,
            emergency_fund=emergency_fund,
        )

        record = {
            "monthly_income": monthly_income,
            "monthly_expenses": monthly_expenses,
            "total_debt": total_debt,
            "number_of_dependents": number_of_dependents,
            "protection_coverage": protection_coverage,
            "emergency_fund": emergency_fund,
            "income_stability": indicators["income_stability"],
            "expense_ratio": indicators["expense_ratio"],
            "emergency_fund_coverage": indicators["emergency_fund_coverage"],
            "debt_burden_ratio": indicators["debt_burden_ratio"],
            "dependent_load": indicators["dependent_load"],
            "protection_readiness": indicators["protection_readiness"],
            "shock_absorption_capacity": indicators["shock_absorption_capacity"],
            "fvs_score": res.data.score,
            "tier": tier
        }
        return record


synthetic_generator = SyntheticDataGenerator()
