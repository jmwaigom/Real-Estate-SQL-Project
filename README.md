# Pinnacle Realty Group: Strategic Data Insights Project


![Screenshot 2024-10-27 230637](https://github.com/user-attachments/assets/927ea357-aa14-4408-8620-88192db6abd7)

### Project Overview
Pinnacle Realty Group is a commercial real estate company managing a diverse portfolio of properties, including office buildings, retail spaces, industrial sites, and residential properties. The company is committed to maximizing profitability while ensuring high tenant satisfaction and effective property maintenance across major cities.

This data analytics project provides critical insights into key business areas such as property performance, leasing trends, tenant retention, and maintenance costs. Using advanced SQL techniques, the project answers a series of business-specific questions designed to help Pinnacle Realty Group make informed, data-driven decisions.

### Objectives
The goal of this project is to empower management with actionable insights for strategic planning and operational improvement. By answering 20 targeted business questions, the analysis uncovers trends and patterns essential for optimizing resources, setting competitive rates, adjusting leasing strategies, and improving tenant engagement.

### Data Model
The project dataset consists of multiple interlinked tables, including:

- **Properties:** Information on each property, categorized by type, location, and size.
- **Leases:** Detailed lease agreements, covering tenant details, lease terms, and rent values.
- **Transactions:** Financial transactions for properties, such as sales, purchases, and renovations.
- **Property Managers:** Data on property managers, including the properties they oversee.
- **Maintenance Logs:** Records of maintenance activities with cost details and service dates.

### Data Issues

Inconsistent data entry was observed in the transactions table. When transactions were ordered by date, some properties displayed multiple consecutive purchase records prior to any eventual sale (if a sale occurred at all). This pattern suggests potential data entry errors or repeated acquisitions without sufficient clarification, which could lead to inaccurate financial analysis and misinterpretation of transaction history

Furthermore, in the transactions table, purchases and renovations were initially recorded as positive values. This approach can be misleading when calculating metrics like average transaction amounts, as these entries represent expenses rather than revenue-generating items like sales. To ensure accurate results, negative values were assigned to purchases and renovations, preventing inflation of average transaction figures and avoiding skewed financial insights.

### Key Insights
Through rigorous analysis, several strategic insights were derived, guiding Pinnacle Realty Group in their investment and operational decisions:

#### 1. Revenue and Rent Trends:

Identified high-revenue properties by ranking properties by rent revenue, both by category and overall. Rolling averages and rent changes provided insights into pricing adjustments and market trends.

#### 2. Maintenance and Cost Efficiency:

Calculated maintenance costs as a percentage of overall expenses to flag high-cost properties. Maintenance logs also helped identify properties with recurring issues, aiding in resource allocation and cost management.

#### 3. Tenant Retention and Lease Stability:

Analyzed tenant loyalty by calculating lease tenures, providing an average tenure for each property type. This information is valuable for enhancing tenant engagement and improving lease renewal rates.

#### 4. Transaction and Cash Flow Analysis:

Calculated 90th percentile values for transaction amounts, highlighting high-value properties. A 12-month moving sum of transactions revealed cash flow trends for better financial planning.

#### 5. Property Management Efficiency:

Ranked property managers based on revenue generated by properties under their oversight. Analyzed average maintenance costs for each manager’s properties, providing a basis for assessing efficiency.

#### 6. Leasing Activity Insights:

Tracked leasing frequency and cumulative lease counts by year, enabling strategic forecasting. Identification of the top 10 most-leased properties provides a focus on high-demand locations.

#### 7. Competitive Pricing and Market Trends:

Calculated average rent for the most recent leases to help set competitive pricing. Additionally, differences in consecutive lease rents were analyzed to flag market trends and provide guidance on pricing adjustments.

### Skills and Techniques Used
This project utilized advanced SQL techniques to derive actionable insights across multiple dimensions. Key functions like DENSE_RANK(), PERCENT_RANK(), and LAG() were employed to analyze transaction and asset performance with precision. Conditional aggregation and CASE statements allowed for complex calculations, enabling effective categorization of transactions and detailed cost management. Date-based calculations, such as rolling sums and interval-based filtering, helped reveal trends over time. Data filtering and ranking methods were also applied to prioritize high-value assets, providing clear visibility into key areas for strategic focus.

### Conclusion
This SQL project demonstrates the power of data analysis in transforming raw data into strategic insights. By focusing on essential business questions, the analysis guides Pinnacle Realty Group in enhancing profitability, improving tenant satisfaction, and optimizing resource allocation. This project showcases SQL as an indispensable tool in real estate data analytics, providing a robust foundation for informed decision-making.
