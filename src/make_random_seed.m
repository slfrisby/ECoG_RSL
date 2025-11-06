function randomSeeds = makeRandomSeed(nPermutations,nPermutationsPerJob)

    % specify:
    % - how many permutations should be run in total
    % - how many of those should be run by each job

    % arguments:
    % - nPermutations (double) - how many permutations in total (must be
    % divisible by nPermsPerJob)
    % - nPermsPerJob (double) - how many permutations each job should run

    if mod(nPermutations, nPermutationsPerJob) ~= 0
        error('nPermutations (%d) must be divisible by the number of permutations per job (%d).', nPermutations, nPermutationsPerJob);
    end

    groupSize = nPermutations/nPermutationsPerJob;

    randomSeeds = arrayfun(@(k) ((k-1)*groupSize + 1 : k*groupSize)', 1:nPermutationsPerJob, 'UniformOutput', false);
    
end