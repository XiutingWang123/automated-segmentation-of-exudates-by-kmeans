function sizeOut = findGoodResolutionForWavelet( sizeIn )
    % Parameters
    maxWavDecom = 2;
    %

    pxToAddC = 2^maxWavDecom - mod(sizeIn(2),2^maxWavDecom);
    pxToAddR = 2^maxWavDecom - mod(sizeIn(1),2^maxWavDecom);
    
    sizeOut = sizeIn + [pxToAddR, pxToAddC];
end