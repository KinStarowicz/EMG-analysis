%% Import data from text file
% Script for importing data from the following text file:
%
%    filename: D:\AGH\SEMESTR_6\Elektroniczna aparatura medyczna\Ćwiczenia projektowe\sygnały eam\sygnały eam\na_stole_5kg_iza.ASC
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
zmeczeniowa_2kg = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Ania\proba_zmeczeniowa_2kg.ASC", opts);
zmeczeniowa_3kg = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Ania\proba_zmeczeniowa_3kg.ASC", opts);
zmeczeniowa_gumaF = readtable("C:\Users\Asus\Desktop\semestr 6\EAM\projekt\eam\Ania\guma_fioletowa_proba_zmeczeniowa.ASC", opts);
%% Convert to output type
zmeczeniowa_2kg = table2array(zmeczeniowa_2kg);
zmeczeniowa_3kg = table2array(zmeczeniowa_3kg);
zmeczeniowa_gumaF = table2array(zmeczeniowa_gumaF);
%% Take only second column
zmeczeniowa_2kg = zmeczeniowa_2kg(:,2);
zmeczeniowa_3kg = zmeczeniowa_3kg(:,2);
zmeczeniowa_gumaF = zmeczeniowa_gumaF(:,2);
%% OBRÓBKA DANYCH
%% Zero crossing    
time = (1:1:10)

zmeczeniowa_2kg_cross = zmeczeniowa_2kg(1:10000,:);
zmeczeniowa_3kg_cross = zmeczeniowa_3kg(1:10000,:);
zmeczeniowa_gumaF_cross = zmeczeniowa_gumaF(1:10000,:);

first_divide_2kg = buffer(zmeczeniowa_2kg_cross, numel(zmeczeniowa_2kg_cross)/10); 
counter_2kg = zeros(10,1)
first_divide_3kg = buffer(zmeczeniowa_3kg_cross, numel(zmeczeniowa_3kg_cross)/10); 
counter_3kg = zeros(10,1)
first_divide_gumaF = buffer(zmeczeniowa_gumaF_cross, numel(zmeczeniowa_gumaF_cross)/10); 
counter_gumaF = zeros(10,1)

for i = 1:10
    for j = 1:999
        if first_divide_2kg(j, i) * first_divide_2kg(j+1, i) < 0
            counter_2kg(i) = counter_2kg(i) + 1;
        end
    end
end

for i = 1:10
    for j = 1:999
        if first_divide_3kg(j, i) * first_divide_3kg(j+1, i) < 0
            counter_3kg(i) = counter_3kg(i) + 1;
        end
    end
end

for i = 1:10
    for j = 1:999
        if first_divide_gumaF(j, i) * first_divide_gumaF(j+1, i) < 0
            counter_gumaF(i) = counter_gumaF(i) + 1;
        end
    end
end

figure()
subplot(1, 2, 1)
plot(zmeczeniowa_2kg_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
ylim([-600 600])
subplot(1, 2, 2)
bar(time, counter_2kg)
title('Częstość występowania amplitudy równej 0 - próba zmęczeniowa 2kg')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;

figure()
subplot(1, 2, 1)
plot(zmeczeniowa_3kg_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
subplot(1, 2, 2)
bar(time, counter_3kg)
title('Częstość występowania amplitudy równej 0 - próba zmęczeniowa 2kg')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;

figure()
subplot(1, 2, 1)
plot(zmeczeniowa_gumaF_cross)
title('Surowy sygnał EMG')
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
subplot(1, 2, 2)
bar(time, counter_gumaF)
title('Częstość występowania amplitudy równej 0 - próba zmęczeniowa guma fioletowa')
xlabel('Czas [s]')
ylabel('Ilość przekroczeń zer')
grid on;
%% Clear temporary variables
clear opts

% Fourier Transform
L_2kg = length(zmeczeniowa_2kg);
L_3kg = length(zmeczeniowa_3kg);
L_gumaF = length(zmeczeniowa_gumaF);

fs = 1000; %sampling frequency
f_2kg = fs*(0:(L_2kg/2))/L_2kg; % FFT frequency from 0 to L/2 data length
f_3kg = fs*(0:(L_3kg/2))/L_3kg;
f_gumaF = fs*(0:(L_gumaF/2))/L_gumaF;

%compute two sided spectrum (-Fmax:Fmax)
p_2kg = fft(zmeczeniowa_2kg);
p_3kg = fft(zmeczeniowa_3kg);
p_gumaF = fft(zmeczeniowa_gumaF);

%divive by L for normalization of the power of the output 
p_2kg = abs(p_2kg/L_2kg);
p_3kg = abs(p_3kg/L_3kg);
p_gumaF = abs(p_gumaF/L_gumaF);

% compute signal sided spectrum
p_2kg=p_2kg(1:L_2kg/2+1);
p_2kg(2:end-1) = 2*p_2kg(2:end-1);

p_3kg=p_3kg(1:L_3kg/2+1);
p_3kg(2:end-1) = 2*p_3kg(2:end-1);

p_gumaF=p_gumaF(1:L_gumaF/2+1);
p_gumaF(2:end-1) = 2*p_gumaF(2:end-1);

%Plotting FFT
figure()
subplot(1, 3, 1)
plot(f_2kg, p_2kg)
xlabel('Częstotliwość [Hz]')
ylabel('Intensywność')
title('FFT (guma fioletowa)')
grid on;

subplot(1, 3, 2)
plot(f_3kg, p_3kg)
xlabel('Częstotliwość [Hz]')
ylabel('Intensywność')
title('FFT (guma czerwona)')
grid on;
ylim([0 20])

subplot(1, 3, 3)
plot(f_gumaF, p_gumaF)
xlabel('Częstotliwość[Hz]')
ylabel('Intensywność')
title('FFT (guma czarna)')
grid on;
%% Rectification
zmeczeniowa_2kg = abs(zmeczeniowa_2kg);
zmeczeniowa_3kg = abs(zmeczeniowa_3kg);
zmeczeniowa_gumaF = abs(zmeczeniowa_gumaF);
%% RMS Mean Power of signal
envelope_2kg = zeros(L_2kg, 1);
envelope_3kg = zeros(L_3kg, 1);
envelope_gumaF = zeros(L_gumaF, 1);

window = 100;
envelope_2kg = sqrt(movmean(zmeczeniowa_2kg.^2, window));
envelope_3kg = sqrt(movmean(zmeczeniowa_3kg.^2, window));
envelope_gumaF = sqrt(movmean(zmeczeniowa_gumaF.^2, window));
%% Normalization with MVC
MVC_2kg = max(zmeczeniowa_2kg);
MVC_2kg_normalised = zeros(L_2kg, 1);
MVC_2kg_normalised = envelope_2kg./MVC_2kg.*100;

MVC_3kg = max(zmeczeniowa_3kg);
MVC_3kg_normalised = zeros(L_3kg, 1);
MVC_3kg_normalised = envelope_3kg./MVC_3kg.*100;

MVC_gumaF = max(zmeczeniowa_gumaF);
MVC_gumaF_normalised = zeros(L_gumaF, 1);
MVC_gumaF_normalised = envelope_gumaF./MVC_gumaF.*100;

figure()
subplot(3, 1, 1)
plot(zmeczeniowa_2kg)
hold on;
plot(envelope_2kg, 'g')
xlabel("Czas [ms]")
ylabel("Amplituda [μV]")
xlim([0 30000])
ylim([0 1000])
title('Normalizacja MVC (próba zmęczeniowa 2kg)')
legend('Sygnał EMG', 'Sygnał znormalizowany')

subplot(3, 1, 2)
plot(zmeczeniowa_3kg)
hold on;
plot(envelope_3kg, 'g')
xlabel("Czas [ms]")
ylabel("Amplituda [μV]")
xlim([0 30000])
title('Normalizacja MVC (próba zmęczeniowa 3kg)')
legend('Sygnał EMG', 'Sygnał znormalizowany')

subplot(3, 1, 3)
plot(zmeczeniowa_gumaF)
hold on;
plot(envelope_gumaF, 'g')
xlabel("Czas [ms]")
ylabel("Amplituda [μV]")
xlim([0 30000])
title('Normalizacja MVC (próba zmęczeniowa guma fioletowa)')
legend('Sygnał EMG', 'Sygnał znormalizowany')


%% ZMECZENIOWA_2KG
figure()

subplot(3,1,1)
plot(zmeczeniowa_2kg,"b")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z obciążeniem 2kg")
legend("sygnał wyjściowy")
xlim([0 30000])
ylim([0 1000])

subplot(3,1,2)
zmeczeniowa_2kg = abs((zmeczeniowa_2kg));
plot(zmeczeniowa_2kg,"b")
hold on
M1 = conv2(zmeczeniowa_2kg, ones(101,1)/101, 'same');
plot(M1,"g")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z obciążeniem 2kg")
legend("moduł z sygnału", "filtracja movingAverage")
xlim([0 30000])
ylim([0 1000])

subplot(3,1,3)
%M2 = movmean(zmeczeniowa_3kg,100);
plot(M1,"g")
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z obciążeniem 3kg")
xlim([0 30000])


%% ZMECZENIOWA_3KG
figure()

subplot(3,1,1)
plot(zmeczeniowa_3kg,"b")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z obciążeniem 3kg")
legend("sygnał wyjściowy")
xlim([0 30000])

subplot(3,1,2)
zmeczeniowa_3kg = abs((zmeczeniowa_3kg));
plot(zmeczeniowa_3kg,"b")
hold on
M2 = conv2(zmeczeniowa_3kg, ones(101,1)/101, 'same');
plot(M2,"g")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z obciążeniem 3kg")
legend("moduł z sygnału", "filtracja movingAverage")
xlim([0 30000])

subplot(3,1,3)
%M2 = movmean(zmeczeniowa_3kg,100);
plot(M2,"g")
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z obciążeniem 3kg")
xlim([0 30000])

%% ZMECZENIOWA_GUMAF

figure()

subplot(3,1,1)
plot(zmeczeniowa_gumaF,"b")
hold on
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z taśma (fioletowa)")
legend("sygnał wyjściowy")
xlim([0 30000])

subplot(3,1,2)
zmeczeniowa_gumaF = abs((zmeczeniowa_gumaF));
plot(zmeczeniowa_gumaF,"b")
hold on
M3 = conv2(zmeczeniowa_gumaF, ones(101,1)/101, 'same');
plot(M3,"g")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z taśma (fioletowa)")
legend("moduł z sygnału", "filtracja movingAverage")
xlim([0 30000])

subplot(3,1,3)
%M3 = movmean(zmeczeniowa_gumaF,100);
plot(M3,"g")
legend("filtracja movingAverage")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")
title("Próba zmęczeniowa z taśma (fioletowa)")
xlim([0 30000])

%% Dopasowanie krzywej do sygnałów movingAverage

t1 = linspace(0,30000, length(M1));
% M1 = M1(:,2);

t2 = linspace(0,30000, length(M2));
% M2 = M2(:,2);

t3 = linspace(0,30000, length(M3));
% M3 = M3(:,2);

%% Initialization.

% Initialize arrays to store fits and goodness-of-fit.
fitresult = cell( 3, 1 );
gof = struct( 'sse', cell( 3, 1 ), ...
    'rsquare', [], 'dfe', [], 'adjrsquare', [], 'rmse', [] );

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( t1, M1 );

% Set up fittype and options.
ft = fittype( 'fourier8' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000575958653158129];

% Fit model to data.
[fitresult1, gof] = fit( xData, yData, ft, opts );


%% Fit: 'untitled fit 2'.
[xData, yData] = prepareCurveData( t2, M2 );

% Set up fittype and options.
ft = fittype( 'sin5' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf];
opts.StartPoint = [222.171291396112 0.00010471975511966 0.207988339945938 80.8126054482825 0.00020943951023932 2.13880446039413 15.7768017437764 0.00125663706143592 0.0763808697892699 14.8832047889512 0.000837758040957278 -0.902319287139351 9.17995042939681 0.00188495559215388 0.821973956911939];

% Fit model to data.
[fitresult2, gof] = fit( xData, yData, ft, opts );


%% Fit: 'untitled fit 3'.
[xData, yData] = prepareCurveData( t3, M3 );

% Set up fittype and options.
ft = fittype( 'sin5' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf -Inf 0 -Inf];
opts.Normalize = 'on';
opts.StartPoint = [1181.52907985172 0.906942421316008 1.84230541896643 532.850448075456 1.81388484263202 -0.786439398224823 72.3610616755714 21.7666181115842 0.661369075202084 69.8283040282117 14.5110787410561 -0.693614595804278 74.5747108397994 5.44165452789605 -0.189083464869004];

% Fit model to data.
[fitresult3, gof] = fit( xData, yData, ft, opts );



%% 

figure()
plot( fitresult1, "r")
hold on
plot( fitresult2, "b")
plot( fitresult3, "g")
legend("Próba zmęczeniowa z obciążeniem 2kg", "Próba zmęczeniowa z obciążeniem 3kg", "Próba zmęczeniowa z taśma (fioletowa)")
xlabel("Time [ms]")
ylabel("Amplitude [μV]")

grid on
hold off

