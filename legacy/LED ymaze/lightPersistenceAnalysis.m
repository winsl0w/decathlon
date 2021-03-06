cThresh=60;                                     % Choice number threshold
n=4;                                            % Number of repeated experiments per fly

tActive=nChoices>cThresh;
R=cell(size(pLight,2)-1,1);
R{1,1}='R-light';
R{1,2}='R-turn';
    
for i=2:n
    
    active=tActive(:,1)&tActive(:,i);
    [COEFF, SCORE, LATENT] = pca(pLight(active,[1 i]));
    R{i,1}=sqrt(LATENT(1)/sum(LATENT));
    [COEFF, SCORE, LATENT] = pca(pRight(active,[1 i]));
    R{i,2}=sqrt(LATENT(1)/sum(LATENT));
end

R
    
%% Bootstrapped R-values

nReps=5000;
BSlight=NaN(nReps,size(pLight,2)-1);
BSturn=NaN(nReps,size(pLight,2)-1);

for i=2:n
    active=tActive(:,1)&tActive(:,i);
    tlDat=pLight(active,[1 i]);
    trDat=pRight(active,[1 i]);
    for j=1:nReps
    [COEFF, SCORE, LATENT] = pca([tlDat(ceil(rand(size(tlDat,1),1)*size(tlDat,1)),1) tlDat(ceil(rand(size(tlDat,1),1)*size(tlDat,1)),2)]);
    BSlight(j,i-1)=sqrt(LATENT(1)/sum(LATENT));
    [COEFF, SCORE, LATENT] = pca([trDat(ceil(rand(size(trDat,1),1)*size(tlDat,1)),1) trDat(ceil(rand(size(trDat,1),1)*size(tlDat,1)),2)]);
    BSturn(j,i-1)=sqrt(LATENT(1)/sum(LATENT));
    end  
end

% Plot bootstrapped R-value distribution and observed R
figure();
bins=linspace(0,1,101);
plot(bins,histc(BSlight,bins,1)/nReps);
hold on
plot(repmat(cell2mat(R(2:end,1))',2,1),[zeros(1,n-1);ones(1,n-1)])
axis([0 1 0 max(max(histc(BSlight,bins,1)/nReps))]);
title('Bootstrapped R values for light choice probability persistence');
legend('Day1-Day2','Day1-Day3','Day1-Day7','Location','Northwest');
hold off

figure();
bins=linspace(0,1,101);
plot(bins,histc(BSturn,bins,1)/nReps);
hold on
plot(repmat(cell2mat(R(2:end,1))',2,1),[zeros(1,n-1);ones(1,n-1)])
axis([0 1 0 max(max(histc(BSturn,bins,1)/nReps))]);
title('Bootstrapped R values for right turn choice probability persistence');
legend('Day1-Day2','Day1-Day3','Day1-Day7','Location','Northwest');
hold off

clearvars -except nChoices pLight pRight R BSlight BSturn