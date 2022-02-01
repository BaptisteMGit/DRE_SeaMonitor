function Alpha = AbsorptionSoundSeaWaterFrancoisGarrison(Freq, temperatureC, Salinity, Depth, pH)
% Compute absorption coefficient in dB / km according to Francois and
% Garrison model 
% Adapted from R code on https://rdrr.io/cran/sonar/src/R/sonar.R

TemperatureKelvin = 273.15 + temperatureC; %ambient temperatureC(Kelvin)
speedOfSound = 1412 + 3.21 * temperatureC + 1.19 * Salinity + 0.0167 * Depth; % Calculate speed of sound (m/s) (according to Francois & Garrison, JASA 72 (6) p1886)

%Boric acid contribution
A1 = (8.86 / speedOfSound ) * 10^(0.78 * pH - 5); % (dB/km/kHz)
P1 = 1; % pressure correction factor
f1 = 2.8 * sqrt(Salinity / 35) * 10^(4 - 1245 / TemperatureKelvin); % (kHz)
Boric = (A1 * P1 * f1 * (Freq^2))/((Freq^2) + sqrt(f1^2)); % boric acid contribution

%MgSO4 contribution
A2 = 21.44 * (Salinity / speedOfSound) * (1 + 0.025 * temperatureC); % (dB/km/kHz)
P2 = 1 - 1.37 * 10^(-4) * Depth + 6.2 * 10^(-9) * (Depth^2);
f2 = (8.17 * 10^(8 - 1990/TemperatureKelvin))/(1 + 0.0018 * (Salinity - 35)); % (kHz)
MgSO4 = (A2 * P2 * f2 * (Freq^2))/((Freq^2) + (f2^2)); % magnesium sulphate contribution

%Pure water contribution
if (temperatureC <= 20)
	A3 = 4.937 * 10^(-4) - 2.59 * 10^(-5) * temperatureC + 9.11 * 10^(-7) * (temperatureC^2) - 1.50 * 10^(-8) * temperatureC^3; % (dB/km/kHz)
else
	A3 = 3.964 * 10^(-4) - 1.146 * 10^(-5) * temperatureC + 1.45 * 10^(-7) * (temperatureC^2) - 6.50 * 10^(-10) * temperatureC^3; % (dB/km/kHz)
end

P3 = 1 - 3.83 * 10^(-5) * Depth + 4.9 * 10^(-10) * (Depth^2);
H2O = A3 * P3 * (Freq^2); % pure water contribution

%Total absorption
Alpha = Boric + MgSO4 + H2O;% total absorption (dB/km)

end
