
%% Import data from text file
% Script for importing data from the following text file:
%
%   filename: D:\AGH\SEMESTR_6\Elektroniczna aparatura medyczna\Ćwiczenia projektowe\sygnały eam\sygnały eam\na_stole_5kg_iza.ASC
%
% Auto-generated by MATLAB on 06-May-2022 16:12:00

%% Setup the Import Options and import the data
clear all;
close all;

opts = delimitedTextImportOptions("NumVariables", 2);

% Specify range and delimiter
opts.DataLines = [32, Inf];
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["MegaWinASCIIfile", "VarName2"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "MegaWinASCIIfile", "TrimNonNumeric", true);
opts = setvaropts(opts, "MegaWinASCIIfile", "ThousandsSeparator", ",");

% Import the data
hantel_LO = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Iza\hantel_wibracyjny_lo_iza.ASC", opts);
hantel_HI = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Iza\hantel_wibracyjny_hi_iza.ASC", opts);

%% Convert to output type
hantel_LO = table2array(hantel_LO);
hantel_HI = table2array(hantel_HI);

%% Clear temporary variables
clear opts
%% OBRÓBKA DANYCH
%% Zero crossing    
time = (1:1:10)

pompki_hantel_LO_cross = hantel_LO(1:10000,2);
pompki_hantel_HI_cross = hantel_HI(1:10000,2);

first_divide_hantel_LO = buffer(pompki_hantel_LO_cross, numel(pompki_hantel_LO_cross)/10); 
counter_hantel_LO = zeros(10,1)
first_divide_hantel_HI = buffer(pompki_hantel_HI_cross, numel(pompki_hantel_HI_cross)/10); 
counter_hantel_HI = zeros(10,1)

for i = 1:10
    for j = 1:999
        if first_divide_hantel_LO(j, i) * first_divide_hantel_LO(j+1, i) < 0
            counter_hantel_LO(i) = counter_hantel_LO(i) + 1;
        end
    end
end

for i = 1:10
    for j = 1:999
        if first_divide_hantel_HI(j, i) * first_divide_hantel_HI(j+1, i) < 0
            counter_hantel_HI(i) = counter_hantel_HI(i) + 1;
        end
    end
end

figure()
subplot(1, 2, 1)
plot(pompki_hantel_LO_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
subplot(1, 2, 2)
bar(time, counter_hantel_LO)
title('Częstość występowania amplitudy równej 0 - hantel wibracyjny mode LO')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;

figure()
subplot(1, 2, 1)
plot(pompki_hantel_HI_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
subplot(1, 2, 2)
bar(time, counter_hantel_HI)
title('Częstość występowania amplitudy równej 0 - hantel wibracyjny mode HI')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;
% Fourier Transform
L_lo = length(hantel_LO);
L_hi = length(hantel_HI);

fs = 1000; %sampling frequency
f_lo = fs*(0:(L_lo/2))/L_lo; % FFT frequency from 0 to L/2 data length
f_hi = fs*(0:(L_hi/2))/L_hi;

%compute two sided spectrum (-Fmax:Fmax)
p1 = fft(hantel_LO(:,2));
p2 = fft(hantel_HI(:,2));

%divive by L for normalization of the power of the output 
p1 = abs(p1/L_lo);
p2 = abs(p2/L_hi);

% compute signal sided spectrum
p1=p1(1:L_lo/2+1);
p1(2:end-1) = 2*p1(2:end-1);
p2=p2(1:L_hi/2+1);
p2(2:end-1) = 2*p2(2:end-1);

%Plotting FFT
figure()
subplot(1, 2, 1)
plot(f_lo, p1)
xlabel('Frequency[Hz]')
ylabel('Intensity')
title('FFT (level - low)')
grid on;

subplot(1, 2, 2)
plot(f_hi, p2)
xlabel('Frequency[Hz]')
ylabel('Intensity')
title('FFT (level - high)')
grid on;
%% Rectification
hantel_LO(:,2) = abs(hantel_LO(:, 2))
hantel_HI(:,2) = abs(hantel_HI(:, 2))
%% RMS Mean Power of signal
envelope_lo = zeros(L_lo, 1);
envelope_hi = zeros(L_hi, 1);
window = 100;
envelope_lo = sqrt(movmean(hantel_LO(:,2).^2, window));
envelope_hi = sqrt(movmean(hantel_HI(:,2).^2, window));
%% Normalization with MVC
MVC_lo = max(hantel_LO(:,2));
MVC_lo_normalised = zeros(L_lo, 1);
MVC_lo_normalised = envelope_lo./MVC_lo.*100;

MVC_hi = max(hantel_HI(:,2));
MVC_hi_normalised = zeros(L_hi, 1);
MVC_hi_normalised = envelope_hi./MVC_hi.*100;

figure()
plot(hantel_LO(:,2))
hold on;
plot(envelope_lo, 'r')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
xlim([0 30000])
title('Normalizacja MVC (level-low)')
legend('EMG signal', 'Normalized signal')

figure()
plot(hantel_HI(:,2))
hold on;
plot(envelope_hi, 'r')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
xlim([0 30000])
title('Normalizacja MVC (level-high)')
legend('EMG signal', 'Normalized signal')
%% HANTEL_LO

figure()

subplot(3,1,1)
plot((hantel_LO(:,2)),"b")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z hantlem wibracyjnym (level - low)")
legend("sygnał wyjściowy")
xlim([0 30000])

subplot(3,1,2)
hantel_LO = abs((hantel_LO));
plot((hantel_LO(:,2)),"b")
hold on
%M1 = movmean(hantel_LO,200);
M1 = conv2(hantel_LO, ones(101,1)/101, 'same');
plot(M1,"g")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z hantlem wibracyjnym (level - low)")
legend("moduł z sygnału", "filtracja movingAverage")
xlim([0 30000])

subplot(3,1,3)
%M2 = movmean(zmeczeniowa_3kg,100);
plot(M1,"g")
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z hantlem wibracyjnym (level - low)")
xlim([0 30000])


%% HANTEL_HI
figure()

subplot(3,1,1)
plot((hantel_HI(:,2)),"b")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z hantlem wibracyjnym (level - high)")
legend("sygnał wyjściowy")
xlim([0 30000])

subplot(3,1,2)
hantel_HI = abs((hantel_HI));
plot((hantel_HI(:,2)),"b")
hold on
%M2 = movmean(hantel_LO,200);
M2 = conv2(hantel_HI, ones(101,1)/101, 'same');
plot(M2,"g")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z hantlem wibracyjnym (level - high)")
legend("moduł z sygnału", "filtracja movingAverage")
xlim([0 30000])

subplot(3,1,3)
plot(M2,"g")
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Zginanie z hantlem wibracyjnym (level - high)")
xlim([0 30000])

%% Dopasowanie krzywej do sygnałów movingAverage

t1 = linspace(0,30000, length(M1));
M1 = M1(:,2);

t2 = linspace(0,30000, length(M2));
M2 = M2(:,2);

%% Initialization.

% Initialize arrays to store fits and goodness-of-fit.
fitresult = cell( 2, 1 );
gof = struct( 'sse', cell( 2, 1 ), ...
    'rsquare', [], 'dfe', [], 'adjrsquare', [], 'rmse', [] );

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( t1, M1 );

% Set up fittype and options.
ft = fittype( 'fourier6' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0 0 0 0 0 0 0 0 0 0 0 0.00136135681655558];

% Fit model to data.
[fitresult1, gof(1)] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult1);
legend( h, 'M1 vs. t1', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 't1', 'Interpreter', 'none' );
ylabel( 'M1', 'Interpreter', 'none' );
grid on

%% Fit: 'untitled fit 2'.
[xData, yData] = prepareCurveData( t2, M2 );

% Set up fittype and options.
ft = fittype( 'fourier6' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0 0 0 0 0 0 0 0 0 0 0 0.00230383461263251];

% Fit model to data.
[fitresult2, gof(2)] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 2' );
h = plot( fitresult2);
legend( h, 'M2 vs. t2', 'untitled fit 2', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 't2', 'Interpreter', 'none' );
ylabel( 'M2', 'Interpreter', 'none' );
grid on


%% 

plot( fitresult1, "r")
hold on
plot( fitresult2, "b")
legend("Zginanie z hantlem wibracyjnym (level - low)", "Zginanie z hantlem wibracyjnym (level - high)")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")

grid on
hold off