%%Reset
close all;
clear all;
clc;

%% Does work with SDR or from recording ?
flogSDR = " Does work with SDR or from recording ? "
flogSDR = input(flogSDR)


if (flogSDR)
    %% Setting up a work device
    connectedRadios = findsdru;
    if strncmp(connectedRadios(1).Status, 'Success', 7)
        radioFound = true;
        platform = connectedRadios(1).Platform;
        switch connectedRadios(1).Platform
            case {'B200','B210'}
                address = connectedRadios(1).SerialNum;
            case {'N200/N210/USRP2','X300','X310','E312'}
                address = connectedRadios(1).IPAddress;
        end
    end
    
        radioRx = comm.SDRuReceiver(...
            'Platform', platform, ...
            'SerialNum', address,...
            'SamplesPerFrame',10000 );
        
        
        %% RX Parameters
        radioRx.CenterFrequency =900e6;
        radioRx.Gain =10;
        radioRx.MasterClockRate = 100e6;
        radioRx.OutputDataType = 'Single';
        radioRx.DecimationFactor=500;
        radioRx.LocalOscillatorOffset=1e6;
        
    
    %%Receiver
    %This function correlates between the two variables:lenoisySignal,Preamble_hMod.
    
    FileSizeIs=0;
    while(~FileSizeIs)
        buffer=[];
        
        if radioFound
            timeCounter_zeroes =500;
            timeCounter_samples=100;
            for i=1:timeCounter_zeroes
                [temp, len] = step(radioRx);
            end
            for i=1:timeCounter_samples
                [x, len] = step(radioRx);
                 if(isreal(x))
                    break;
                end
                buffer=[buffer; x];
            end
            if(isreal(x))
                continue
            end
        end
    end
end 

load eNodeBOutput.mat           % Load I/Q capture of eNodeB output
figure;
Complex_Pair_Double = single(eNodeBOutput);
stem(abs(Complex_Pair_Double));
title('Buffer Samples')