function [auc,F1,sensitivity,specificity,accuracy] = AUC(class_vector,score_vector,varargin)
% Author: Harm Derksen
% Clinical Informatics Lab, Unversity of Michigan
% December 2018
%
% function [auc,F1,sensitivity,specificity,accuracy] = AUC(class_vector,score_vector)
%
% INPUTS:
% class_vector...[numeric, vector]
%                Vector of 0's and 1's, ground truth binary classification.
%                '0' is a negative classification, '1' is positive.
%
% score_vector...[{single, double}, vector]
%                A vector with the output scores from a binary
%                classification algorithm. Scores range from 0 to 1.
%                Higher scores means more likely to belong to class '1' and 
%                lower scores mean more likely to belong to class '0')
%
% method...[numeric, >=1, <=5, OPTIONAL, DEFAULT=1]
%          Different methods for choosing a point on the ROC curve for 
%          which we compute the F1 scores, sensitivity,specificity and 
%          accuracy.
%               
%          The methods choose the point on the ROC curve where...
%          * 1: ... the F1-score is maximal.
%          * 2: ... sensitivity+specificity is maximal.
%          * 3: ... the ROC curve closest to (0,1).
%          * 4: ... the sensitivity and specificity are about the same.
%          * 5: ... the accuracy is maximal.
%
% OUTPUTS:
% [auc, F1, sensitivity, specificity, accuracy]...The standard metrics, 
% calculated at the point on the ROC using the chosen method.
%%

% Validate inputs. If 'method' is not provided, default method=1
[class_vector, score_vector, method] = ...
    parse_inputs(class_vector, score_vector, varargin);

% Set up data by sorting the classes according to the ordering of the
% scores.
[sorted_scores,permutation]=sort(score_vector);
sorted_class_vector=class_vector(permutation,1);

% Initialize variables.
[n,~]=size(score_vector);
total_positives=sum(class_vector); % Total # of positive class datapoints.
total_negatives=n-total_positives; % Total # of negative class datapoints.

% Initialize a vector to keept rack of the number of false negatives that
% occur for each cutoff value.
false_negative_vector(1,1)=sorted_class_vector(1,1);
for j=2:n
    % As we increase the cutoff for positive classification to the next
    % value, we increase the number of false negatives if the new value
    % belonged to the positive class.
    
    false_negative_vector(j,1) = sorted_class_vector(j,1) + ...
        false_negative_vector(j-1,1);
    %% TODO: ITERATE OVER UNIQUE SCORES, NOT OVER ALL SCORES.
end
% Calculate TN, TP, and FP from the FN. 
true_negative_vector  = (1:n)' - false_negative_vector;
true_positive_vector  = total_positives - false_negative_vector;
false_positive_vector = total_negatives - true_negative_vector;

% Calculate sensitivity, specificity, accuracy, and F1-score.
sensitivity_vector=true_positive_vector/total_positives;
% the sensitivity is also the recall and the true positive rate
specificity_vector=true_negative_vector/total_negatives;
% specificity is also the true negative rate
accuracy_vector=(true_positive_vector+true_negative_vector)/n;
F1_vector = 2*true_positive_vector ./ ...
    (2*true_positive_vector+false_positive_vector+false_negative_vector);

% Compute AUC by integrating. 
%% TODO: edit integration method to work on non-step functions
auc = sum((specificity_vector-[0;specificity_vector(1:end-1)]).*sensitivity_vector);

% Display ROC, compute maximal value for returned parameters according to
% input method. 
fprintf('\nArea Under the ROC curve: %1.4f\n',auc);
if method==1
    [~,x]=max(F1_vector);   
    fprintf('\nMethod 1: choosing point on ROC curve where F1 is maximal');
elseif method==2
    [~,x]=max(sensitivity_vector+specificity_vector);
    fprintf('\nMethod 2: choosing point on ROC curve where sensitivity+specificity is maximal');
elseif method==3
    [~,x]=min((1-sensitivity_vector).^2+(1-specificity_vector).^2);
    fprintf('\nMethod 3: choosing point on ROC curve closest to (0,1)'); 
elseif method==4
    x=min(find(specificity_vector>sensitivity_vector,1,'first'));
    fprintf('\nMethod 4: choosing point on ROC curve where sensitivity and specificity are about the same');
elseif method==5
    [~,x]=max(accuracy_vector);   
    fprintf('\nMethod 5: choosing point on ROC curve where accuracy is maximal');
end
    
F1=F1_vector(x,1);
sensitivity=sensitivity_vector(x,1);
specificity=specificity_vector(x,1);
accuracy=accuracy_vector(x,1);

fprintf('\nF1 score: %1.4f\n',F1);
fprintf('Sensitivity: %1.4f\n',sensitivity);
fprintf('Specificity: %1.4f\n',specificity);
fprintf('Accuracy: %1.4f\n\n',accuracy);


figure(1);
plot(1-specificity_vector,sensitivity_vector);
% this plots the ROC curve
title('ROC curve');
xlabel('1 - specificity');
%xticks([0:.1:1]);
ylabel('sensitivity');
%yticks([0:.1:1]);
axis([0,1,0,1]);
hold on;
scatter([1-specificity],[sensitivity]);
hold off;

figure(2);
plot(1-specificity_vector,F1_vector);
% this plots the F1 curve
title('F1 score');
xlabel('1 - specificity');
%xticks([0:.1:1]);
ylabel('F1');
%yticks([0:.1:1]);
axis([0,1,0,1]);
hold on;
scatter([1-specificity],[F1]);
hold off;

end

%% INPUT VALIDATION
% Alexander Wood for BCIL 2019.
function [classes, scores, method] = parse_inputs(classes, scores, varargin)

% The classes must be of type DOUBLE. Cannot contain NaN values or empty
% values. Must be a vector of size [N 1] (column vector). Values must be
% integers, either 0 or 1.
classes = double(classes);

% Make sure it's a column.
if size(classes,1)<size(classes,2)
    classes=classes';
end
validateattributes(classes,{'double'},{'nonnan','nonempty','vector', ...
    'size', [NaN 1], 'binary'}, mfilename, 'classes');

% Input scores must be same size as input classes and range from 0 to 1.
N = size(classes,1);
if size(scores,1)<size(scores,2)
    scores=scores';
end
validateattributes(scores, {'single','double'}, {'nonnan' 'nonempty', ...
    'vector', 'size', [N 1], 'nonnegative', '<=', 1}, mfilename, 'scores');

% Default values for optional arguments: method
method = 1;

% Parse any optional arguments.
args = varargin{1};
if ~isempty(args)
    % Too many input.
    if length(args)>1
        error('Too many inputs provided.');
    end
    method = args{1};
    validateattributes(method,{'numeric'},{'scalar', 'integer', ...
        '<=', 5, '>=', 1}, mfilename, 'method');
end
end

