function theta=logisticRegression()
% logistic regression�Ĳ���theta,������matlab�Դ�����glmfit���
x = [0.0 0.1 0.7 1.0 1.1 1.3 1.4 1.7 2.1 2.2]';
y = [0 0 1 0 0 0 1 1 1 1]'; 
theta = glmfit(x, [y ones(10,1)], 'binomial', 'link', 'logit')
end