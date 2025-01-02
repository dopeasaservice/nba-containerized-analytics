async function fetchData(endpoint) {
    try {
        const response = await fetch(`/api/${endpoint}`);
        if (!response.ok) throw new Error('Network response was not ok');
        return await response.json();
    } catch (error) {
        console.error('Error fetching data:', error);
        return null;
    }
}

async function initializeCharts() {
    const playerData = await fetchData('player-rankings');
    const teamData = await fetchData('team-stats');

    if (playerData) {
        const top10Players = playerData.slice(0, 10);
        new Chart(document.getElementById('playerChart'), {
            type: 'bar',
            data: {
                labels: top10Players.map(p => p.Name),
                datasets: [{
                    label: 'Efficiency Rating',
                    data: top10Players.map(p => p.EfficiencyRating),
                    backgroundColor: 'rgba(54, 162, 235, 0.8)'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    }
                }
            }
        });
    }

    if (teamData) {
        new Chart(document.getElementById('teamChart'), {
            type: 'bar',
            data: {
                labels: teamData.map(t => t.Team),
                datasets: [{
                    label: 'Team Score',
                    data: teamData.map(t => t.TeamScore),
                    backgroundColor: 'rgba(255, 99, 132, 0.8)'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    }
                }
            }
        });
    }
}

document.addEventListener('DOMContentLoaded', initializeCharts);
