import Foundation

class HomepageOrchestrator: HomepageProvider {
    
    weak var client: HomepageClient?
    
    // p = portrait
    // t = thumb
    // c = card
    private var projects: [HomepageProject] = [
        HomepageProject(
            context: 1,
            source: .kickstarter,
            assets: [
                .image(URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!),
                .video(previewURL: URL(string: "https://s3.amazonaws.com/backit.com/tempt/youre-awesome.mp4")!, videoURL: URL(string: "https://s3.amazonaws.com/backit.com/tempt/youre-awesome.mp4")!),
                .image(URL(string: "https://cdn.collect.backit.com/pictures/2/f/c/a/e/2fcae53923676aea72f9eeb7fae822e0t.jpg")!)
            ],
            name: "KEYTO: The Key to Burning Fat Faster",
            numberOfBackers: 1234,
            comment: .comments(500),
            isEarlyBird: true,
            fundedPercent: 0.9
        )
    ]

    func viewDidLoad() {
        client?.didReceiveProjects(projects)
    }
    
    func didTapAsset(project: HomepageProject) {
        
    }
    
    func didTapBackit(project: HomepageProject) {
        
    }
    
    func didTapComment(project: HomepageProject) {
        
    }
}
