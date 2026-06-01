The piazza post that led to this project "
Hello Ralph and Yidi, having read through the slides for this weeks lecture I've had a question regarding spurious/non spurious regressions and granger causality. Specifically, I wanted to check if given knowledge of shared underlying seasonality it is possible to disprove or prove the existence of a granger causal relationship by modelling a seasonally adjusted version of the original series, effectively controlling for seasonality.Consider for example Google Trends relative search interest for Vampire and Divorce topics with strong shared seasonal patters spiking at same intervals(usually october and February).


After iteratively selecting the order of the lag 4 lags were sufficient to reduce residual autocorrelation  being non significant. It is thus possible to carry out a granger style test to see if adding a vampire components allows one to better predict divorce searches. Adf test on residuals is added to confirm stationarity of residuals and consistency of the estimates.

tThe predictive improvement(Increase in LL/Reduction in RSS) of the model with vampires over the null model with vampires is too extreme to have come from the null distribution and we thus have evidence of the alternative "granger causality hypothesis".The stationarity of residuals is confirmed.To unmask the spurious result the seasonal component estimated by STL is subtracted from each series and the test is rerun.



The test can no longer reject the null of no improvent in prediction over the null(no vampire model), after controlling for seasonality there's not enough evidence that the  vampire search series granger causes the divorce search series. 



My question is is this a good way to deal with spurious regressions such as these?And is the evidence above sufficient to disprove the absurd albeit interesting "Dracula->Divorce" causal hypothesis?"

