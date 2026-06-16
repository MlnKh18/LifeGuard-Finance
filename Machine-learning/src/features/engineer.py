class FeatureEngineer:
    """Computes the 7 FVS indicator sub-scores (S1–S7) from raw flat financial data.

    Each method returns a score between 0 and 100.
    """

    def compute_income_stability(self, monthly_income: float) -> float:
        """S1: Income Stability Score.
        Evaluates baseline income adequacy compared to living standards (ideal: 10,000,000 IDR).
        """
        if monthly_income <= 0:
            return 0.0
        return min(50.0 + (monthly_income / 10_000_000.0) * 50.0, 100.0)

    def compute_expense_ratio(self, monthly_income: float, monthly_expenses: float) -> float:
        """S2: Expense Ratio Score.
        Lower expense-to-income ratio yields a higher score (ideal: <= 30%).
        """
        if monthly_income <= 0:
            return 0.0
        ratio = monthly_expenses / monthly_income
        if ratio <= 0.3:
            return 100.0
        elif ratio <= 0.7:
            return 100.0 - ((ratio - 0.3) / 0.4) * 40
        elif ratio <= 1.0:
            return 60.0 - ((ratio - 0.7) / 0.3) * 50
        else:
            return max(10.0 - (ratio - 1.0) * 10, 0.0)

    def compute_emergency_fund_coverage(self, emergency_fund: float, monthly_expenses: float) -> float:
        """S3: Emergency Fund Coverage Score.
        Measures how many months of expenses the emergency fund covers (ideal: 6 months).
        """
        if monthly_expenses <= 0:
            return 100.0 if emergency_fund > 0 else 50.0
        months = emergency_fund / monthly_expenses
        if months >= 6.0:
            return 100.0
        else:
            return (months / 6.0) * 100.0

    def compute_debt_burden_ratio(self, total_debt: float, monthly_income: float) -> float:
        """S4: Debt Burden Ratio Score.
        Estimates monthly debt payment as 5% of total debt and checks ratio to income.
        """
        estimated_monthly_payment = total_debt * 0.05
        if monthly_income <= 0:
            return 0.0 if total_debt > 0 else 100.0
        ratio = estimated_monthly_payment / monthly_income
        if ratio <= 0.1:
            return 100.0
        elif ratio <= 0.3:
            return 100.0 - ((ratio - 0.1) / 0.2) * 30
        elif ratio <= 0.6:
            return 70.0 - ((ratio - 0.3) / 0.3) * 40
        else:
            return max(30.0 - (ratio - 0.6) * 75, 0.0)

    def compute_dependent_load(self, number_of_dependents: int, monthly_income: float) -> float:
        """S5: Dependent Load Score.
        Fewer dependents relative to income yields higher score. Estimates cost at 1,500,000 IDR per dependent.
        """
        if number_of_dependents <= 0:
            return 100.0
        if monthly_income <= 0:
            return 0.0
        estimated_cost = number_of_dependents * 1_500_000.0
        ratio = estimated_cost / monthly_income
        if ratio <= 0.2:
            return 100.0
        elif ratio <= 0.4:
            return max(80.0 - ((ratio - 0.2) / 0.2) * 30, 0.0)
        else:
            return max(50.0 - (ratio - 0.4) * 100.0, 0.0)

    def compute_protection_readiness(self, protection_coverage: float, monthly_income: float) -> float:
        """S6: Protection Readiness Score.
        Evaluates protection adequacy compared to annual income (ideal: 5x annual income).
        """
        annual_income = monthly_income * 12.0
        if annual_income <= 0:
            return 0.0 if protection_coverage > 0 else 100.0
        ratio = protection_coverage / annual_income
        return min(ratio / 5.0, 1.0) * 100.0

    def compute_shock_absorption_capacity(self, monthly_income: float, monthly_expenses: float, total_debt: float) -> float:
        """S7: Shock Absorption Capacity Score.
        Measures financial buffer — surplus after all obligations.
        """
        estimated_monthly_payment = total_debt * 0.05
        obligations = monthly_expenses + estimated_monthly_payment
        surplus = monthly_income - obligations
        if monthly_income <= 0:
            return 0.0
        surplus_ratio = surplus / monthly_income
        if surplus_ratio >= 0.3:
            return 100.0
        elif surplus_ratio >= 0.1:
            return 60.0 + ((surplus_ratio - 0.1) / 0.2) * 40
        elif surplus_ratio >= 0:
            return 30.0 + (surplus_ratio / 0.1) * 30
        else:
            return max(30.0 + surplus_ratio * 100.0, 0.0)

    def compute_all(
        self,
        monthly_income: float,
        monthly_expenses: float,
        total_debt: float,
        number_of_dependents: int,
        protection_coverage: float,
        emergency_fund: float,
    ) -> dict[str, float]:
        return {
            "income_stability": round(self.compute_income_stability(monthly_income), 2),
            "expense_ratio": round(self.compute_expense_ratio(monthly_income, monthly_expenses), 2),
            "emergency_fund_coverage": round(self.compute_emergency_fund_coverage(emergency_fund, monthly_expenses), 2),
            "debt_burden_ratio": round(self.compute_debt_burden_ratio(total_debt, monthly_income), 2),
            "dependent_load": round(self.compute_dependent_load(number_of_dependents, monthly_income), 2),
            "protection_readiness": round(self.compute_protection_readiness(protection_coverage, monthly_income), 2),
            "shock_absorption_capacity": round(self.compute_shock_absorption_capacity(monthly_income, monthly_expenses, total_debt), 2),
        }


feature_engineer = FeatureEngineer()
