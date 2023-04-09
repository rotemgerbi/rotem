%% Accepts the signal and adds attentive
% Returns a signal and amount attentive

function modSignalattenuated = AttenuatedB( modSignal )
    % Random attenFactor
    attenFactordB = randi([4 20],1,1);
    attenFactor=10^(attenFactordB/10);
    
    % The attentive
    modSignal = double(modSignal);
    modSignalattenuated=modSignal./attenFactor;
end

