library(readxl)

file_path <- "C:/Users/Sebastian/Documents/GitHub/labo2023r/src/workflow-inicial/EXP06/B/testblm.xlsx"

df <- read_excel(file_path)

model <- lm(GananciaPromedio ~ Ratio + DesvSTD, data = df)

df$predicted <- predict(model)

max_row <- df[which.max(df$predicted), ]

summary(model)




# Assuming your dataframe is named 'df' with variables GananciaPromedio, Ratio, and DesvSTD

# Fit a generalized linear model (GLM) with gamma family and log link
model <- glm(GananciaPromedio ~ Ratio + DesvSTD, data = df, family = Gamma(link = "log"))

# View the model summary
summary(model)

# Obtain predicted values
df$predicted2 <- predict(model)

# You can also extract the estimated coefficients
coefs <- coef(model)


