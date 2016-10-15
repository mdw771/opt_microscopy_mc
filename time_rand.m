function xi = time_rand()
    % generate a random seed based on CPU time and return a random number
    seed = cputime * 100;
    rng(seed);
    xi = rand();
end