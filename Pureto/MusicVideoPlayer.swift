//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 3/8/23.
//

import SwiftUI
import AVFoundation
import AVKit

struct MusicVideoPlayer: UIViewControllerRepresentable {     
    var player: AVPlayer?    // The controller object that manages the playback of the video
     
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        // Create a new AVPlayerViewController and pass it a reference to the player
        let controller = AVPlayerViewController()
        player?.allowsExternalPlayback = true
        player?.audiovisualBackgroundPlaybackPolicy = .automatic
        controller.videoGravity = .resizeAspectFill
        controller.player = player
        controller.delegate = context.coordinator
        controller.modalPresentationStyle = .automatic
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.entersFullScreenWhenPlaybackBegins = false
        controller.exitsFullScreenWhenPlaybackEnds = false
        controller.allowsPictureInPicturePlayback = true
        controller.showsPlaybackControls = true
        controller.restoresFocusAfterTransition = true
        controller.updatesNowPlayingInfoCenter = true
        return controller
    }
    // In our case we do not need to update our `AVPlayerViewController` when AVPlayer changes
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
    // Creates the coordinator that is used to handle and communicate changes in `AVPlayerViewController`
    func makeCoordinator() -> MusicVideoPlayerCoordinator {
        MusicVideoPlayerCoordinator(self)
    }
}

public class MusicVideoPlayerCoordinator: NSObject {
    var parent: MusicVideoPlayer
 
    init(_ parent: MusicVideoPlayer) {
        self.parent = parent
    }
}

extension MusicVideoPlayerCoordinator: AVPlayerViewControllerDelegate {
    // This method is called after the user clicks on the full-screen icon and the player begins to go fullscreen
    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
        let isPlaying = (playerViewController.player?.timeControlStatus ==  AVPlayer.TimeControlStatus.playing)
        coordinator.animate(alongsideTransition: nil) { context in
            // Add coordinated animations
            if context.isCancelled {
                // Still embedded inline
            } else {
                // Presented full screen
                // Take strong reference to playerViewController if needed
            }
            if isPlaying {
                playerViewController.player?.play()
            }
        }
    }
     
    // This method is called after the user clicks on the close icon and the player starts to go out of fullscreen
    public func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
    ) {
//        let isPlaying = playerViewController.player?.isPlaying ?? false
        let isPlaying = (playerViewController.player?.timeControlStatus ==  AVPlayer.TimeControlStatus.playing)
        coordinator.animate(alongsideTransition: nil) { context in
            // Add coordinated animations
            if context.isCancelled {
                // Still full screen
            } else {
                // Embedded inline
                // Remove strong reference to playerViewController if held
            }
            if isPlaying {
                playerViewController.player?.play()
            }
        }
    }
     
    // This method returns whether the embedded AVPlayerViewController should be dismissed after PiP starts
    // Unless we are going to handle it some other way, we need this to always return false
    public func playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart(_ playerViewController: AVPlayerViewController) -> Bool {
        return false
    }
}
